#!/bin/bash
set -e

rooms="study lounge hallwaylarge bathroomguest bedroom1 bedroom2 bedroom3 kitchen bathroommain"

for room in $rooms; do
  echo "room todo: $room"
done

for room in $rooms; do
  if ping -c 1 -W 1 tablet-$room.imagilan &> /dev/null
  then
    echo "doing room: $room"
    adb connect tablet-$room.imagilan &> /dev/null
    adb -s tablet-$room.imagilan push templates/fully-auto-settings.json /sdcard/fully-auto-settings.json &> /dev/null
    adb -s tablet-$room.imagilan reboot &
    sleep 2
    adb -s tablet-$room.imagilan disconnect &> /dev/null
  fi
done
