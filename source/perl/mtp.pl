#!/usr/bin/perl
use warnings; use strict;
use feature 'current_sub';
$" = ', ';

# TODO:
# * options
#   * fail control
#   * offline mode
#   * omit / only tally

my $author    = 'Nico Pareigis';
my ($program) = $0 =~ m{^.*/(.+)$};
my $version   = '0.0.7';

my %OPTS = ( colour => 1, json => 0, json_pretty => 0 );
my %JSON = ();
my ($PACKAGE, $CLASS) = ('')x2;

my sub err($$) { # exit_code, message
  printf STDERR "$program: %s\n", $_[1];
  exit($_[0]) if $_[0] > 0;
}

my sub mvn($$$) { # exit_code, severity, message
  my $sev = uc $_[1];
  printf STDOUT "[%s] %s\n", $OPTS{colour} ? colored($sev, $sev) : $sev, $_[2];
  exit($_[0]) if $_[0] > 0;
}

my sub json {
  print JSON::PP->new->pretty($OPTS{json_pretty})->encode(\%JSON);
  exit $JSON{maven}{exitCode};
}

my sub help {
  print <<~EOF
  NAME
      $program - `mvn test` parser

  SYNOPSIS
      $program [OPTS] [DIR|FILE]

  DESCRIPTION
      $program parses maven's `test` output in an effort to reduce clutter and
      visual noise, whilst improving the legibility of test results. To achieve
      this, a not insignificant portion of the output is discarded, parts of
      which may be deemed vital by some users.

      By default $program walks upwards the directory tree in an effort to find
      a pom.xml file, starting from the working directory. DIR|FILE may be used
      if maven is to be run in a different directory, or with a differently
      named project file.

  OPTIONS
      -h | --help
          Print help information and exit.

      -j | --json
          Output test data in JSON format, requires JSON::PP to be installed.

      -n | --no-colour
          Disable coloured output, makes Term::ANSIColor an optional dependency.

      -p | --prettify-json
          Output JSON data in prettified format, implies -j.

      -v | --version
          Print version information and exit.

  EXIT STATUS
      0, on success.
      1, on argument, dependency, or filesystem error.
      2, on fatal maven error.

  DEPENDENCIES
      External:
      mvn

      Modules:
      Cwd
      JSON::PP        (required with -j, -p)
      Term::ANSIColor (optional with -n)

  VERSION
      $version

  AUTHOR(S)
      $author
  EOF
  ; exit 0;
}

my sub version {
  printf "%s %s %s\n", $program, $version, $author;
  exit 0;
}

my sub mvn_avail {
  my $exec = 0;
  foreach (split ':', $ENV{PATH}) {
    chop if m{/$};
    if (not -d $_.'/mvn' and -x _) { $exec = 1; last; }
  }
  err 1, 'mvn executable not found in $PATH' unless $exec;
}

my sub mod_avail {
  my @missing = ();
  my @mods = (
    { mod => 'Cwd', args => 'qw(chdir)' },
    { mod => 'JSON::PP', cond => $OPTS{json} },
    { mod => 'Term::ANSIColor',
      cond => $OPTS{colour},
      args => '4.00 qw(color colored coloralias)',
      cb => sub { Term::ANSIColor::coloralias('INF', 'bold blue');
        Term::ANSIColor::coloralias('ERR', 'bold red'); } }
  );

  foreach (@mods) {
    next if ($_->{cond} // 1) == 0;
    eval 'use '.$_->{mod}.' '.($_->{args} // '');
    $@ ? push @missing, $_->{mod} : (defined $_->{cb} and $_->{cb}());
  }

  err 1, "dependency not met - @missing" if @missing;
}

my sub dep_check {
  mvn_avail();
  mod_avail();
}

my sub validate_root($) {
  my $root = shift;
  if (-d $root) {
    $root =~ s{/$}{};
    not -f $root.'/pom.xml' and err 1, 'target directory does not contain pom.xml';
    $JSON{maven}{rootDirectory} = Cwd::abs_path($root);
  } elsif (-f $root) {
    $root =~ s{/?([^/]+?)$}{};
    $JSON{maven}{pomXml} = $1;
    $JSON{maven}{rootDirectory} = Cwd::abs_path($root || '.');
  } else {
    err 1, 'target \''.$root.'\' does not exist'
  }
}

my sub find_mvn_root_rec($) { local $_ = shift;
  if (m{^/$}) {
    if ($OPTS{json}) {
      $JSON{maven}{rootDirectory} = undef;
      $JSON{maven}{exitCode} = 2;
      json();
    } else {
      mvn 2, 'ERR', 'Fatal: No maven root found';
    }
  }

  opendir DH, $_ or err 1, 'failed to open dirhandle \''.$_.'\'';
    return $_ if grep /^$JSON{maven}{pomXml}$/, readdir DH;
  closedir DH or err 1, 'failed to close dirhandle \''.$_.'\'';

  __SUB__->(Cwd::abs_path($_.'/..'));
}

my sub find_mvn_root {
  $JSON{maven}{pomXml} //= 'pom.xml';
  $JSON{maven}{rootDirectory} //= find_mvn_root_rec(Cwd::getcwd());

  mvn 0, 'INF', 'Found maven root at '.$JSON{maven}{rootDirectory}
    if not $OPTS{json};
}

my sub parse_package($$) {
  mvn 0, 'INF', 'Testing package '.$_[0] if not $OPTS{json} and $PACKAGE ne $_[0];
  ($PACKAGE, $CLASS) = (shift, shift);
  mvn 0, 'INF', 'Running '.$CLASS if not $OPTS{json};
}

my sub parse_tests($$) {
  mvn 0, substr($1, 0, 3), $CLASS.' results:' if not $OPTS{json};
  $2 =~ /^(\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)/;

  my @keys = ( 'tests', 'fail', 'error', 'skip' );
  # WARN: black magic ahead
  no strict 'refs';
  foreach (0..$#keys) {
    $JSON{testResults}{$PACKAGE}{$CLASS}{$keys[$_]} = ${$_+1};
    $JSON{testResults}{tallied}{$keys[$_]} += ${$_+1};
  }
  use strict;

  if (not $OPTS{json}) {
    print '  Ran     : ', $1, "\n";
    print '  Passed  : ', ($1 - $2 - $3), "\n";
    print '  Failed  : ', $2, "\n";
    print '  Errored : ', $3, "\n";
    print '  Skipped : ', $4, "\n";
  }
}

my sub parse_errors($) {
  my $FH = shift;
  while (local $_ = <$FH>) {
    last if /^\[INFO\]/;
    /^\[ERROR\]\s+(\w+)\.(\w+)/;
    # TEST: ensure this works with multi-package projects
    push @{$JSON{testResults}{$PACKAGE}{failedTests}{$1}}, $2;
  }
}

my sub summary {
  my %total = %{$JSON{testResults}{tallied}};
  mvn 0, 'INF', 'Summary';
  mvn 0, $total{fail} + $total{error} == 0 ? 'INF' : 'ERR', 'Test summary:';
  print '  Ran     : ', $total{tests}, "\n";
  print '  Passed  : ', $total{tests} - $total{fail} - $total{error}, "\n";
  print '  Failed  : ', $total{fail}, "\n";
  print '  Errored : ', $total{error}, "\n";
  print '  Skipped : ', $total{skip}, "\n";

  my %results = %{$JSON{testResults}};
  foreach (sort keys %results) { # packages
    my %package = %{$results{$_}};
    next if /^tallied$/ or not $package{failedTests};

    mvn 0, 'ERR', 'Failed tests ('.$_.'):';
    foreach (sort keys %{$package{failedTests}}) { # classes
      my $class = $_;
      print '  ', $class, ' -> ', $_, "\n" foreach @{$package{failedTests}{$class}};
    }
  }

  my $sev = $JSON{maven}{buildStatus} =~ /^SUCCESS$/ ? 'INF' : 'ERR';
  mvn 0, $sev, 'Build '.lc $JSON{maven}{buildStatus};
  mvn 0, 'INF', 'Time taken: '.$JSON{maven}{totalTime};
}

# option processing
my $root;
while (local $_ = shift) {
  if (/^(?:-h|--help)$/) {
    help();
  }
  elsif (/^(?:-j|--json)$/) {
    $OPTS{json} = 1;
  }
  elsif (/^(?:-n|--no-colour)$/) {
    $OPTS{colour} = 0;
  }
  elsif (/^(?:-p|--prettify-json)$/) {
    $OPTS{json} = 1; $OPTS{json_pretty} = 1;
  }
  elsif (/^(?:-v|--version)$/) {
    version();
  }
  elsif (/^-{1,2}\w+/) {
    err 1, 'illegal argument - '.$_;
  }
  elsif (/^--$/) {
    $root = shift if @ARGV; last;
  }
  else {
    $root = $_; last;
  }
}

# preliminary checks
dep_check();
do { validate_root($root); undef $root; } if $root;
find_mvn_root();

# parse test output
open my $FH, '-|', 'mvn test -f '.$JSON{maven}{rootDirectory}.'/'.$JSON{maven}{pomXml}.' 2>/dev/null'
    or err 1, 'failed to spawn mvn';
  while (<$FH>) {
    next unless /^\[\w+\]/;

    parse_package($1, $2) if /^\[INFO\] Running ([\w.]+)\.(\w+)$/;
    parse_tests($1, $2)   if /^\[(\w+)\] Tests run: (.*), Time elapsed:/;
    parse_errors($FH)     if /^\[ERROR\] Errors:/;

    $JSON{maven}{buildStatus} = $1 if /^\[INFO\] BUILD (\w+)$/;
    $JSON{maven}{totalTime}   = $1 if /^\[INFO\] Total time:\s+(.*)$/;
  }
  summary() if not $OPTS{json};
close $FH or $? = $? == 256 ? 1 : $?;
$JSON{maven}{exitCode} = $?;

$OPTS{json}
  ? json()
  : do {
    mvn $JSON{maven}{exitCode}, 'ERR', 'Fatal: maven returned non-zero exit status'
      if $JSON{maven}{exitCode} > 0;
  };
