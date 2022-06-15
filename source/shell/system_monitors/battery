#!/bin/bash
Bat=$(< /sys/class/power_supply/BAT0/capacity)

if (( $Bat <= 15 )); then
  dunstify -u critical -h string:x-dunst-stack-tag:batWarn \
    "Battery: $Bat%"
  exit 0
fi

if (( $Bat <= 30 )); then
  dunstify -u normal -h string:x-dunst-stack-tag:batWarn \
    "Battery: $Bat%"
  exit 0
fi

dunstify -u low -h string:x-dunst-stack-tag:batWarn \
  "Battery: $Bat%"
