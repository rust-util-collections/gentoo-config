#!/usr/bin/env bash

setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0

chmod a+w /sys/devices/platform/applesmc.768/leds/smc\:\:kbd_backlight/brightness
chmod a+w /sys/class/backlight/intel_backlight/brightness

current=`cat ~fh/.kbcache_backlight`
if [[ $current -lt 100 ]]; then
    current=100
fi
echo $current  > /sys/class/backlight/intel_backlight/brightness
