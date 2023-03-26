#!/usr/bin/perl
use warnings; use strict;
use feature 'current_sub';
$" = ', ';

# mvn-test-parser - works only with java maven projects

# TODO:
# * add documentation
# * option for uncoloured output
# * option for json output
# * change `die` to err calls

my $author    = 'Nico Pareigis';
my ($program) = $0 =~ m{^.*/(.+)$};
my $version   = 0.0.1;

my sub err {
  printf STDERR "$program: %s\n", $_[1];
  exit($_[0]) if $_[0] > 0;
}
my sub mvn_err {
  printf STDERR "[%s] %s\n", colored('ERR', 'ERR'), $_[1];
  exit($_[0]) if $_[0] > 0;
}


my @missing_deps = ();

eval 'use Cwd qw(chdir)';
push @missing_deps, 'Cwd' if $@;
eval 'use Term::ANSIColor 4.00 qw(color colored coloralias)';
push @missing_deps, 'Term::ANSIColor' if $@;

err 2, "dependency not met - @missing_deps" if @missing_deps;

Term::ANSIColor::coloralias('INF', 'bold blue');
Term::ANSIColor::coloralias('ERR', 'bold red');

my $cwd = Cwd::getcwd();
my $root = 0;


my sub find_mvn_root_rec($) {
  local $_ = shift;
  mvn_err 2, 'Fatal: No maven root found' if m{^/$};

  opendir DH, $_ or err 1, 'failed to open dirhandle \''.$_.'\'';
    my @files = readdir DH;
  closedir DH or err 1, 'failed to close dirhandle';

  return if grep /^pom\.xml$/, @files;
  $cwd = Cwd::abs_path($cwd.'/..');
  __SUB__->($cwd);
}

my sub find_mvn_root($) {
  print '[', colored('INF', 'INF'), '] Looking for maven root directory... ', "\n";
  find_mvn_root_rec(shift);
  print '[', colored('INF', 'INF'), '] Found maven root at ', $cwd, "\n";
  chdir $cwd;
}

find_mvn_root($cwd);


my ($PACK, $FILE) = ('')x2;
my ($tt, $tf, $te, $ts) = (0)x4;

# FIX: test maven installed / available in path
open FH, '-|', 'mvn test 2>/dev/null' or die $!;

while (<FH>) {
  next if not /^\[\w+\]/;

  if (/^\[INFO\] Running ([\w.]+)\.(\w+)$/) {
    if ($1 ne $PACK) {
      # print "\n" if $PACK;
      $PACK = $1;
      print '[', colored('INF', 'INF'), '] Testing package ', $PACK, "\n";
    }
    $FILE = $2;
    print '[', colored('INF', 'INF'), '] Running ', $FILE, "\n";
  }

  if (/^\[(\w+)\] Tests run: (.*), Time elapsed:/) {
    my $sev = substr($1, 0, 3);
    $2 =~ /^(\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)/;
    my ($t, $f, $e, $s) = ($1, $2, $3, $4);
    print '[', colored($sev, $sev), '] ', $FILE, ' results:', "\n";
    print '  Ran     : ', $t, "\n";
    print '  Passed  : ', ($t - $e), "\n";
    print '  Failed  : ', $f, "\n";
    print '  Errored : ', $e, "\n";
    print '  Skipped : ', $s, "\n";
  }

  # FIX: push each test to array and eval after loop + include tally
  if (/^\[ERROR\] Errors:/) {
    print '[', colored('ERR', 'ERR'), '] Failed tests:', "\n";
    until (not local $_ = <FH>) {
      last if /^\[INFO\]/;
      /^\[ERROR\]\s+(\w+)\.(\w+)/;
      print '  ', $1, ' -> ', $2, "\n";
    }
  }

  if (/^\[INFO\] BUILD (\w+)$/) {
    my $sev = $1 =~ /^SUCCESS$/ ? 'INF' : 'ERR';
    print '[', colored($sev, $sev), '] Build '.lc $1, "\n";
  }

  if (/^\[INFO\] Total time:\s+(.*)$/) {
    print '[', colored('INF', 'INF'), '] Took '.$1, "\n";
  }
}

# FIX:
# * don't die when maven has non-zero exit status
# * or "mvn_err $?, maven fatal"
close FH or die $!;
