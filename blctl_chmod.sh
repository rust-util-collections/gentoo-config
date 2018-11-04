#!/bin/bash

setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0
chmod a+w /sys/class/backlight/intel_backlight/brightness
