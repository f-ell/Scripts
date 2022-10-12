#!/usr/bin/perl
use strict;
use warnings;

$SIG{INT}     = sub { &SigHandler('SigInt'); };
our $Program  = 'perl-keemount';
our $Version  = '0.0.1';

our sub ErrHandler {
  printf STDERR "\nError: %s\n", $_[1];
  exit($_[0]) if ($_[0] > 0);
}

our sub SigHandler {
  &ErrHandler(130,  'Keyboard Interrupt.')      if ($_[0] eq 'SigInt');
  &ErrHandler(1,    'Device not connected.')    if ($_[0] eq 'DeviceErr');
  &ErrHandler(1,    'Keepass couldn\'t open.')  if ($_[0] eq 'KPErr');
  &ErrHandler(2,    'Mount failure.')           if ($_[0] eq 'MntErr');
  &ErrHandler(2,    'Unmount failure.')         if ($_[0] eq 'UMntErr');
  &ErrHandler(3,    'Databse error.')           if ($_[0] eq 'DbErr');
}

my $Unmount = 'True';
my $Uuid    = '2D09-D357';

# my @BlockInfo = split / /, '2D09-D357 sdb1 NICO_USB'; # used for testing without USB connected

# [0] = uuid; [1] = name; [2] = label
my @BlockInfo = split / /, `lsblk --raw -o uuid,name,label | grep $Uuid`;
if (!scalar @BlockInfo) { &SigHandler('DeviceErr'); }

my ($Mnt) = `mount` =~ /$BlockInfo[1] on (.*) type/;

chomp($BlockInfo[2]); my $DbPath;
$Mnt ? $DbPath = $Mnt : $DbPath = "/run/media/$ENV{USER}/$BlockInfo[2]";
$DbPath = "$DbPath/6_KeePass/db/Database.kdbx";

if (!$Mnt) {
  system("udisksctl mount -b /dev/$BlockInfo[1] 12>/dev/null") == 0
    or die(&SigHandler('MntErr'));
} else {
  $Unmount = 'False';
  printf "Partition already mounted - opening database.\n";
}

system("keepass $DbPath" 12>/dev/null) == 0
  or die(&SigHandler('KPErr'));

if ($Unmount eq 'True') {
  system("udisksctl unmount -b /dev/$BlockInfo[1] 12>/dev/null") == 0
    or die(&SigHandler('UMntErr'));
}

