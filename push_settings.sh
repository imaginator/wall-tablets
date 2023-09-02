#!/bin/bash

# if $1 is not empty, use it as the rooms list
if [ -z "$1" ]; then
  rooms="study lounge hallwaylarge bedroom1 bedroom2 bedroom3 kitchen bathroommain bathroomguest"
else
  rooms=$1
fi

for room in $rooms; do
  echo "todo: $room"
done

for room in $rooms; do
  echo -n "$room: "
  if ping -c 2 -W 2 tablet-$room.imagilan &>/dev/null; then
    # trap failures
    RC=0
    trap 'RC=1' ERR

    adb connect tablet-$room.imagilan &>/dev/null

    # fully kiosk settings
    adb -s tablet-$room.imagilan push templates/fully-auto-settings.json /sdcard/fully-auto-settings.json &>/dev/null
    adb -s tablet-$room.imagilan shell pm grant com.fullykiosk.emm android.permission.WRITE_SECURE_SETTINGS # remove the system bars

    # other tablet settings
    adb -s tablet-$room.imagilan shell setprop persist.adb.tcp.port 5555 # keep adb via wifi enabled
    adb -s tablet-$room.imagilan shell setprop persist.sys.timezone Europe/Berlin
    adb -s tablet-$room.imagilan shell settings put global bluetooth_on 0
    adb -s tablet-$room.imagilan shell settings put global wifi_scan_throttle_enabled 0
    adb -s tablet-$room.imagilan shell settings put secure location_providers_allowed -gps
    adb -s tablet-$room.imagilan shell settings put secure location_providers_allowed +network
    adb -s tablet-$room.imagilan shell settings put system accelerometer_rotation 1
    adb -s tablet-$room.imagilan shell settings put system screen_brightness_mode 1 # auto brightness mode

    if RC=0; then
      echo "done"
      # adb reboot without waiting for the device to come back
      timeout 2 adb -s tablet-$room.imagilan reboot
      adb -s tablet-$room.imagilan disconnect &>/dev/null
    else
      echo "failed"
    fi
  else
    echo "ping failed"
  fi
done
