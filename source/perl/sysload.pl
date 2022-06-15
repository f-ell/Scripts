#!/usr/bin/perl
use warnings;
use strict;
use constant STAT => '/proc/stat';
use constant MEMINFO => '/proc/meminfo';

$SIG{INT} = sub { printf "\nError: Keyboard Interrupt.\n"; exit(130); };

open(FH, '<', STAT) or die("$!");
  my @PrevFields = split(' ', readline(FH), 6);
  seek FH, 0, 0; sleep 1;
  my @NewFields = split(' ', readline(FH), 6);
close(FH) or die("$!");

my $PrevLoad = 0, my $NewLoad = 0;
for (my $i=1; $i<4; $i++) {
  $PrevLoad += $PrevFields[$i];
  $NewLoad  += $NewFields[$i];
}
my $PrevTotal = $PrevLoad + $PrevFields[4];
my $NewTotal  = $NewLoad  + $NewFields[4];
my $Cpu = 100.0 * ($NewLoad - $PrevLoad) / ($NewTotal - $PrevTotal);

# my ($Mem) = `free -m` =~ /Mem:\s+\d+\s+(\d+)/;
open(FH, '<', MEMINFO) or die("$!");
  my ($MemTotal) = <FH> =~ /MemTotal:\s+(\d+) kB/;
  <FH>;
  my ($MemAvail) = <FH> =~ /MemAvailable:\s+(\d+) kB/;
close(FH) or die("$!");
my $MemUsed = ($MemTotal - $MemAvail) / 1024;

printf "CPU: %.1f%% | MEM: %.0f MiB\n", $Cpu, $MemUsed;

