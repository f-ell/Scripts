#!/usr/bin/perl
use strict;
use warnings;

open(FH, '<', '/sys/class/power_supply/BAT0/status') or die("$!");
  my $Status = readline(FH);
close(FH) or die("$!");
$Status = '+' if ($Status =~ /Charging.*/);
$Status = '-' if ($Status =~ /Discharging.*/);
$Status = '#' if ($Status =~ /Full.*/);

open(FH, '<', '/sys/class/power_supply/BAT0/capacity') or die("$!");
  my $Capacity = readline(FH);
close(FH) or die("$!");
chomp($Capacity);

my $Urgency;
if ($Capacity <= 15) {
  $Urgency = 'critical';
} elsif ($Capacity <= 30) {
  $Urgency = 'normal';
} else {
  $Urgency = 'low';
}

my $Notification =
  "dunstify -u $Urgency -h string:x-dunst-stack-tag:batWarn 'Battery: $Capacity% ($Status)'";

system($Notification) == 0 or die("$!");

