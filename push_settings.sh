#!/bin/bash
set -e

# if $1 is not empty, use it as the rooms list
if [ -z "$1" ]
then
  rooms="study lounge hallwaylarge bedroom1 bedroom2 bedroom3 kitchen bathroommain bathroomguest"
else
  rooms=$1
fi

for room in $rooms; do
  echo "todo: $room"
done

for room in $rooms; do
  if ping -c 2 -W 2 tablet-$room.imagilan &> /dev/null
  then
    adb connect tablet-$room.imagilan &> /dev/null

    # fully kiosk settings
    adb -s tablet-$room.imagilan push templates/fully-auto-settings.json /sdcard/fully-auto-settings.json &> /dev/null
    adb -s tablet-$room.imagilan shell pm grant com.fullykiosk.emm android.permission.WRITE_SECURE_SETTINGS # remove the system bars

    # other tablet settings
    adb -s tablet-$room.imagilan shell setprop persist.sys.timezone Europe/Berlin
    adb -s tablet-$room.imagilan shell settings put system accelerometer_rotation 1
    adb -s tablet-$room.imagilan shell settings put system screen_brightness_mode 1 # auto brightness mode (1=automatic)
    adb -s tablet-$room.imagilan shell settings put global bluetooth_on 0
    adb -s tablet-$room.imagilan shell cmd uimode night yes
    adb -s tablet-$room.imagilan shell settings put global network_avoid_bad_wifi 0 # we only use one AP, if that's down, keep trying.
    adb -s tablet-$room.imagilan shell settings put global wifi_scan_throttle 0 # don't throttle wifi scans

    # reboot
    adb -s tablet-$room.imagilan reboot &
    sleep 1
    echo "done: $room"
    adb -s tablet-$room.imagilan disconnect &> /dev/null
  fi
done
