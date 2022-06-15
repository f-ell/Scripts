#!/bin/sh
# DEPENDENCIES
#   brightnessctl
# SYNOPSIS:
#   /path/to/script u|d|s (up|down|set) [0-100] {value in percent}

i=; Inc=${2:-10}; Bctl='brightnessctl -q'
case $1 in
  d) i=0;;
  u) i=1;;
  s) i=2;;
esac

[ -z $i ] && { $Bctl s 30%; exit; }
[ $i -eq 0 ] && { $Bctl s $Inc-%; exit; }
[ $i -eq 1 ] && { $Bctl s +$Inc%; exit; }
[ $i -eq 2 ] && { $Bctl s $Inc%; exit; }
