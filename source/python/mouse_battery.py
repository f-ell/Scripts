#!/usr/bin/python
from openrazer.client import DeviceManager

device_manager = DeviceManager()

mouse = None
for device in device_manager.devices:
    if device.name == "Razer Viper Ultimate (Wireless)":
        mouse = device

if mouse.is_charging:
    status = '+'
else:
    status = '-'

print(f"Battery: {mouse.battery_level}% ({status})")

