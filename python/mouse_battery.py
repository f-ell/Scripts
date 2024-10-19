#!/usr/bin/python
from openrazer.client import DeviceManager as devmgr

mouse = None
for dev in devmgr().devices:
    if dev.name == "Razer Viper Ultimate (Wireless)":
        mouse = dev

if mouse == None:
    print('Mouse not connected!')
    exit()

if mouse.is_charging:
    status = '+'
else:
    status = '-'

print(f"Battery: {mouse.battery_level}% ({status})")
