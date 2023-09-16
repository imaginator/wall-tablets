#!/bin/bash

# check if the environment variable $PASS is set
if [ -z "$PASS" ]; then
  echo "Please set the environment variable \$PASS to the fully-kiosk password."
  exit 1
fi

# if $1 is not empty, use it as the rooms list
if [ -z "$1" ]; then
  rooms="study lounge hallwaylarge bedroom1 bedroom2 bedroom3 kitchen bathroommain bathroomguest"
else
  rooms=$1
fi

for room in $rooms; do
  echo "todo: $room"
done
echo -e "\n"

for room in $rooms; do
  echo -n "$room: "
  if 
    curl http://tablet-$room:2323/ &>/dev/null; then
    # trap failures
    RC=0
    trap 'RC=1' ERR
      # upload the settings file
      curl http://tablet-$room:2323/?cmd=uploadSettingsFile\&password=$PASS \
        --header 'Content-Type: multipart/form-data;' \
        --form 'filename=@templates/fully-auto-settings.json;type=application/json' \
        --silent &> /dev/null
      echo -n "uploaded settings... "
      # enable the settings file
      curl -X GET http://tablet-$room:2323/?cmd=importSettingsFile\&filename=fully-auto-settings.json\&password=$PASS --silent &> /dev/null
      echo -n "imported settings... "
    if RC=0; then
      echo "done"
        # for good measure, reboot the device 
        curl -X GET http://tablet-$room:2323/?cmd=rebootDevice\&password=$PASS &> /dev/null
    else
      echo "failed"
    fi
  else
    echo "not connectable"
  fi
done
