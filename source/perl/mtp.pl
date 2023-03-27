#!/usr/bin/perl
use warnings; use strict;
use feature 'current_sub';
$" = ', ';

# mvn-test-parser - test result parser for java maven projects

# TODO:
# * add documentation
# * options
#   * json output
#   * dump output (i.e. wait for mvn to finish)
#   * uncoloured output
#   * omit failed test summary
#   * omit tally
#   * only tally

my $author    = 'Nico Pareigis';
my ($program) = $0 =~ m{^.*/(.+)$};
my $version   = 0.0.2;

my sub err($$) { # exit_code, message
  printf STDERR "$program: %s\n", $_[1];
  exit($_[0]) if $_[0] > 0;
}

my sub mvn($$$) { # exit_code, severity, message
  my $sev = uc $_[1];
  printf STDOUT "[%s] %s\n", colored($sev, $sev), $_[2];
  exit($_[0]) if $_[0] > 0;
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
  my @missing_deps = ();

  eval 'use Cwd qw(chdir)';
  push @missing_deps, 'Cwd' if $@;
  eval 'use Term::ANSIColor 4.00 qw(color colored coloralias)';
  push @missing_deps, 'Term::ANSIColor' if $@;

  err 1, "dependency not met - @missing_deps" if @missing_deps;
}

my sub dep_check {
  mvn_avail();
  mod_avail();
  Term::ANSIColor::coloralias('INF', 'bold blue');
  Term::ANSIColor::coloralias('ERR', 'bold red');
}

my sub find_mvn_root_rec($) { local $_ = shift;
  mvn 2, 'ERR', 'Fatal: No maven root found' if m{^/$};

  opendir DH, $_ or err 1, 'failed to open dirhandle \''.$_.'\'';
    return $_ if grep /^pom\.xml$/, readdir DH;
  closedir DH or err 1, 'failed to close dirhandle \''.$_.'\'';

  $_ = Cwd::abs_path($_.'/..');
  __SUB__->($_);
}

my sub find_mvn_root {
  my ($cwd, $root) = (Cwd::getcwd(), 0);
  mvn 0, 'INF', 'Looking for maven root directory...';
  $cwd = find_mvn_root_rec($cwd);
  mvn 0, 'INF', 'Found maven root at '.$cwd;
  chdir $cwd;
}

# preliminary checks
dep_check();
find_mvn_root();

# parse test output
my ($PACKAGE, $CLASS, $TIME, $BUILD) = ('')x4;
my (@tally, @failed) = ()x2;

open FH, '-|', 'mvn test 2>/dev/null' or err 1, 'failed to spawn \'mvn test\'';

while (<FH>) {
  next unless /^\[\w+\]/;

  if (/^\[INFO\] Running ([\w.]+)\.(\w+)$/) {
    if ($1 ne $PACKAGE) {
      $PACKAGE = $1;
      mvn 0, 'INF', 'Testing package '.$PACKAGE;
    }
    $CLASS = $2;
    mvn 0, 'INF', 'Running '.$CLASS;
  }

  if (/^\[(\w+)\] Tests run: (.*), Time elapsed:/) {
    mvn 0, substr($1, 0, 3), $CLASS.' results:';
    $2 =~ /^(\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)/;
    my ($t, $f, $e, $s) = ($1, $2, $3, $4);

    my $i = 0;
    $tally[$i++] += $_ foreach ($t, $f, $e, $s);
    undef $i;

    print '  Ran     : ', $t, "\n";
    print '  Passed  : ', ($t - $e), "\n";
    print '  Failed  : ', $f, "\n";
    print '  Errored : ', $e, "\n";
    print '  Skipped : ', $s, "\n";
  }

  if (/^\[ERROR\] Errors:/) {
    while (local $_ = <FH>) {
      last if /^\[INFO\]/;
      /^\[ERROR\]\s+(\w+)\.(\w+)/;
      push @failed, [$1, $2];
    }
  }

  if (/^\[INFO\] BUILD (\w+)$/) { $BUILD = $1; }
  if (/^\[INFO\] Total time:\s+(.*)$/) { $TIME = $1; }
}

# test summary
mvn 0, 'INF', 'Summary';
mvn 0, $tally[1] + $tally[2] == 0 ? 'INF' : 'ERR', 'Test summary:';
print '  Ran     : ', $tally[0], "\n";
print '  Passed  : ', $tally[0] - $tally[1] - $tally[2], "\n";
print '  Failed  : ', $tally[1], "\n";
print '  Errored : ', $tally[2], "\n";
print '  Skipped : ', $tally[3], "\n";

if (@failed) {
  mvn 0, 'ERR', 'Failed tests:';
  print '  ', $_->[0], ' -> ', $_->[1], "\n" foreach @failed;
}

my $sev = $BUILD =~ /^SUCCESS$/ ? 'INF' : 'ERR';
mvn 0, $sev, 'Build '.lc $BUILD;
mvn 0, 'INF', 'Time taken: '.$TIME;

close FH or $? = $? == 256 ? 1 : $?;
$? > 0 and mvn $?, 'ERR', 'Fatal: maven returned non-zero exit status';
