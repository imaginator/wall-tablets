#!/bin/bash
set -xe
rooms="study kitchen lounge hallwaylarge bathroommain bathroomguest bedroom1 bedroom2 bedroom3"

for room in $rooms; do
  echo "Deploying to $room"
  adb connect tablet-$room.imagilan
  adb -s tablet-$room.imagilan push templates/fully-auto-settings.json /sdcard/fully-auto-settings.json 
  # adb -s tablet-$room.imagilan shell am start -a android.intent.action.REBOOT
  # adb -s tablet-$room.imagilan shell am force-stop com.fullykiosk.emm
  # adb -s tablet-$room.imagilan shell am start -n   com.fullykiosk.emm/de.ozerov.fully.FullyActivity
  adb -s tablet-$room.imagilan reboot &
  sleep 2
  adb -s tablet-$room.imagilan disconnect
done
