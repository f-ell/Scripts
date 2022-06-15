#!/usr/bin/perl
use strict;
use warnings;

my $Program = 'perl-sysload';
my $Version = '0.0.1';

my ($Cpu) = `top -bn1` =~ /(\d{1,3}\.\d) id,/;
($Cpu) = (100 - $Cpu) =~ /(\d{1,3}\.\d)/;
$Cpu = '0.0' if (!$Cpu);

my ($Mem) = `free -m` =~ /Mem:\s*\d*\s*(\d*)/;

printf "CPU $Cpu% | MEM $Mem MiB\n";
