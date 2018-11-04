#!/bin/bash

setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0

path=/sys/class/backlight/intel_backlight/brightness

echo 600 > $path
chmod a+w $path
