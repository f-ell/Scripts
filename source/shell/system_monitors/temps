#!/bin/sh
while :; do
  sleep 30

  Cpu=$(sensors | grep -A3 "Core 0" | sort -k3)
  Cpu=${Cpu%.* \(high*}; Cpu=${Cpu##*+}

  [ $Cpu -ge 75 ] \
    && dunstify -a highTemp -h string:x-dunst-stack-tag:tempWarn \
    "High Temperature Detected"
  [ $Cpu -ge 90 ] \
    && dunstify -a critTemp -h string:x-dunst-stack-tag:tempwarn \
    "CRITICAL CPU TEMPERATURE: $Cpu°C"
done
