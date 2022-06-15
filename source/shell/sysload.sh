#!/bin/zsh
Cpu=${${"$(rg %Cpu <(top -bn1))"% id,*}##*, }
Cpu=${"$(( (1000 - ${Cpu}e1) / 10 ))":0:4}
(( ${#Cpu#*.} == 0 )) && Cpu+=0

if (( ${#Cpu%.*} == 1 )); then
  Cpu=${Cpu:0:3}
else
  Cpu=${Cpu:0:4}
fi

Mem=$(awk '{print $3}' <(rg Mem: <(free -m)))

echo "CPU $Cpu% | MEM $Mem MiB"
