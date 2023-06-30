#!/bin/bash
source wallpanel-setup-functions.sh
wakelock_version="3.4.0"
wallpanel_version="0.10.4 Build 0"
export room=$1 # envsubst needs global variables

get_a_room $room
adb -s tablet-$room.imagilan:5555 kill-server

# run as non-root
adb connect tablet-$room.imagilan:5555 && sleep 2
adb -s tablet-$room.imagilan:5555  unroot
install_wakelock_app
install_wallpanel_app
set_system_settings
set_wallpanel_as_launcher
start_wakelock_app

# run as root 
adb -s tablet-$room.imagilan:5555 root && sleep 5

set_wakelock_settings
set_wallpanel_settings $1
disable_lock_screen
#remove_unneeded_apps
restart_tablet
