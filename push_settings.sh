#!/bin/bash
set -xe
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
  if ping -c 2 -W 2 tablet-$room &>/dev/null; then
    # trap failures
    RC=0
    trap 'RC=1' ERR

    adb connect tablet-$room &>/dev/null

    adb -s tablet-$room install -r -g /tmp/Fully-Kiosk-Browser-v1.53.1-emm.apk # -g for granting all permissions -r for reinstalling
    adb -s tablet-$room shell dpm set-device-owner com.fullykiosk.emm/de.ozerov.fully.DeviceOwnerReceiver
    adb shell appops set com.fullykiosk.emm GET_USAGE_STATS allow

    # fully kiosk settings
    adb -s tablet-$room push templates/fully-auto-settings.json /sdcard/fully-auto-settings.json &>/dev/null
    adb -s tablet-$room shell pm grant com.fullykiosk.emm android.permission.WRITE_SECURE_SETTINGS # remove the system bars

    # other tablet settings
    adb -s tablet-$room shell setprop persist.adb.tcp.port 5555 # keep adb via wifi enabled
    adb -s tablet-$room shell setprop persist.sys.timezone Europe/Berlin
    adb -s tablet-$room shell settings put global bluetooth_on 0
    adb -s tablet-$room shell settings put global stay_on_while_plugged_in 7         # OR'd values together (USB charging is actually "AC charging")
    adb -s tablet-$room shell settings put global wifi_network_suggestions_enabled 0 # disable drop down wifi suggestions
    adb -s tablet-$room shell settings put global wifi_scan_always_enabled 0         # disable wifi scanning from apps (system is enabled)
    adb -s tablet-$room shell settings put secure accessibility_enabled 0            # disable accessibility
    adb -s tablet-$room shell settings put secure location_providers_allowed -gps
    adb -s tablet-$room shell settings put secure location_providers_allowed +network
    adb -s tablet-$room shell settings put secure skip_first_use_hints 1 # disable first use hints
    adb -s tablet-$room shell settings put system accelerometer_rotation 1
    adb -s tablet-$room shell settings put system screen_brightness 200    # set brightness to 0
    adb -s tablet-$room shell settings put system screen_brightness_mode 1 # auto brightness mode
    adb -s tablet-$room shell settings put system screen_off_timeout 0     # disable screen timeout

    if RC=0; then
      echo "done"
      # adb reboot without waiting for the device to come back
      timeout 2 adb -s tablet-$room reboot
      adb -s tablet-$room disconnect &>/dev/null
    else
      echo "failed"
    fi
  else
    echo "ping failed"
  fi
done
