#!/bin/bash

bldb='/sys/class/backlight/intel_backlight/brightness'
step=$((`cat /sys/class/backlight/intel_backlight/max_brightness` / 20))

current=`cat $bldb`
new=$current
if [ "$1" == "up" ];then
     new=$(($current + $step))
elif [ "$1" == "down" ];then
     new=$(($current - $step))
fi

if [ $new -le 0 ];then
     new=0
fi

echo $new > $bldb
current=`cat $bldb`
