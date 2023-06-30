#!/bin/bash
set -x 
function get_a_room() {
  room=$1
  if [[ $(echo "$room" | grep -LE 'kitchen|lounge|study|hallwaylarge|bathroommain|bathroomguest|bedroom1|bedroom2|bedroom3') ]]; then
    echo "Missing room parameter"
    exit 1
  fi
  echo "Deploying to $room"
}

function install_wakelock_app {
  echo "checking wakelock versions"
  wakelock_installed_version=$(adb -s tablet-$room.imagilan:5555 shell dumpsys package eu.thedarken.wldonate | grep versionName | awk -F"=" '{print $2}')
  echo "installed version: $wakelock_installed_version"
  echo "desired version: $wakelock_version"

  if [ "$wakelock_version" == "$wakelock_installed_version" ]; then
    echo "correct version installed"
  else
    echo "installing wakelock version $wakelock_version"
    if [[ ! -f /tmp/wakelockapp.apk ]]; then
      echo "downloading correct version"
      curl -L -o /tmp/wakelockapp.apk https://github.com/d4rken-org/wakelock/releases/download/v2.4/eu.thedarken.wldonate-v2.5-d-20005-41bfa54.apk
    fi
    adb -s tablet-$room.imagilan:5555 install -r /tmp/wakelockapp.apk

  fi
}

function install_wallpanel_app {
  echo "checking wallpanel versions"
  wallpanel_installed_version=$(adb -s tablet-$room.imagilan:5555 shell dumpsys package xyz.wallpanel.app | grep versionName | awk -F"=" '{print $2}')
  echo "installed version: $wallpanel_installed_version"
  echo "desired version: $wallpanel_version"

  if [ "$wallpanel_version" == "$wallpanel_installed_version" ]; then
    echo "correct version installed"
  else
    echo "installing wallpanel app version: $wallpanel_version"
    if [[ ! -f /tmp/WallPanelApp-prod-universal-release.apk ]]; then
      echo "downloading correct version"
      curl -L -o /tmp/WallPanelApp-prod-universal-release.apk https://github.com/TheTimeWalker/wallpanel-android/releases/download/v0.10.5/WallPanelApp-universal-v0-10-5.apk
    fi
    adb -s tablet-$room.imagilan:5555 install -r /tmp/WallPanelApp-prod-universal-release.apk
  fi
}

function set_system_settings {
  echo "installing system settings"
  # for finding settings:
  # adb -s tablet-$room.imagilan:5555 shell settings list system
  # adb -s tablet-$room.imagilan:5555 shell settings list global
  # adb -s tablet-$room.imagilan:5555 shell settings list secure
  # https://android.googlesource.com/platform/tools/tradefederation/+/54de8d285a4e253ea9f8b65d3e3070644f661aad/src/com/android/tradefed/targetprep/DeviceSetup.java

  adb -s tablet-$room.imagilan:5555 shell appops set android TOAST_WINDOW deny # this would deny all toasts from Android System
  adb -s tablet-$room.imagilan:5555 shell setprop persist.adb.tcp.port 5555    # keep adb -s tablet-$room.imagilan:5555 via wifi enabled
  adb -s tablet-$room.imagilan:5555 shell setprop persist.sys.timezone Europe/Berlin

  # global prefs
  adb -s tablet-$room.imagilan:5555 shell settings put global bluetooth_on 0
  adb -s tablet-$room.imagilan:5555 shell settings put global network_avoid_bad_wifi 0   # stay connected even if network issues
  adb -s tablet-$room.imagilan:5555 shell settings put global stay_on_while_plugged_in 1 # OR'd values together (USB charging is actually "AC charging")
  adb -s tablet-$room.imagilan:5555 shell settings put global wifi_on 1
  adb -s tablet-$room.imagilan:5555 shell settings put global wifi_scan_always_enabled 1
  adb -s tablet-$room.imagilan:5555 shell settings put global wifi_wakeup_available 1
  adb -s tablet-$room.imagilan:5555 shell settings put global wifi_wakeup_enabled 1

  # secure prefs
  adb -s tablet-$room.imagilan:5555 shell settings put secure double_tap_to_wake 1
  adb -s tablet-$room.imagilan:5555 shell settings put secure double_tap_to_wake_up 1
  adb -s tablet-$room.imagilan:5555 shell settings put secure screensaver_activate_on_dock 0
  adb -s tablet-$room.imagilan:5555 shell settings put secure screensaver_activate_on_sleep 0
  adb -s tablet-$room.imagilan:5555 shell settings put secure screensaver_enabled 0
  adb -s tablet-$room.imagilan:5555 shell settings put secure wake_gesture_enabled 1

  # system prefs
  adb -s tablet-$room.imagilan:5555 shell settings put system accelerometer_rotation 1
  adb -s tablet-$room.imagilan:5555 shell settings put system screen_brightness_mode 1 # auto brightness mode (1=automatic)
  adb -s tablet-$room.imagilan:5555 shell settings put system screen_off_timeout 30000 # milliseconds before screen sleep
  adb -s tablet-$room.imagilan:5555 shell settings put system volume_system 0

  # https://android.googlesource.com/platform/frameworks/base/+/master/cmds/svc/src/com/android/commands/svc/PowerCommand.java#46
  adb -s tablet-$room.imagilan:5555 shell svc power stayon ac # from adb -s tablet-$room.imagilan:5555 shell dumpsys battery
  adb -s tablet-$room.imagilan:5555 shell svc wifi enable
}

function set_wakelock_settings() {
  echo "installing wakelock settings"
  # need root to write to /data
  #room=$1
  #echo $room
  echo "adding wakelock prefs"
  adb -s tablet-$room.imagilan:5555 shell am force-stop eu.thedarken.wldonate # before updating prefs / since disable doesn't kill
  adb -s tablet-$room.imagilan:5555 shell chmod -R 777 /data/data/eu.thedarken.wldonate/shared_prefs
  adb -s tablet-$room.imagilan:5555 push ../templates/settings_core.xml /data/data/eu.thedarken.wldonate/shared_prefs/settings_core.xml
  adb -s tablet-$room.imagilan:5555 shell dumpsys deviceidle whitelist +eu.thedarken.wldonate # magical wakelock powers
}

function set_wallpanel_settings() {
  echo "installing wallpanel settings"
  # need root to write to /data
  #room=$1
  #echo $room
  echo "adding wallpanel prefs"
  adb -s tablet-$room.imagilan:5555 shell am force-stop xyz.wallpanel.app # before updating prefs / since disable doesn't kill
  envsubst '$room' <../templates/xyz.wallpanel.app_preferences.xml >/tmp/xyz.wallpanel.app_preferences.xml
  adb -s tablet-$room.imagilan:5555 shell mkdir -m 777 -p /data/data/xyz.wallpanel.app/shared_prefs
  adb -s tablet-$room.imagilan:5555 push /tmp/xyz.wallpanel.app_preferences.xml /data/data/xyz.wallpanel.app/shared_prefs/xyz.wallpanel.app_preferences.xml
  adb -s tablet-$room.imagilan:5555 shell chmod -R 777 /data/data/xyz.wallpanel.app/shared_prefs
  adb -s tablet-$room.imagilan:5555 shell dumpsys deviceidle whitelist +xyz.wallpanel.app # magical wakelock powers
}

function disable_lock_screen {
  echo "disabling lock screen"
  # Disable lock screen
  adb -s tablet-$room.imagilan:5555 shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'1\' WHERE name = \'lockscreen.disabled\'\"
  adb -s tablet-$room.imagilan:5555 shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'0\' WHERE name = \'lockscreen.password_type\'\"
  adb -s tablet-$room.imagilan:5555 shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'0\' WHERE name = \'lockscreen.password_type_alternate\'\"
}

function remove_unneeded_apps {
  echo "removing cruf"
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.calculator2
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.calendar
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.camera2
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.contacts
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.deskclock
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.documentsui # file manager
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.email
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.exchange
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.gallery3d
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.managedprovisioning
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.onetimeinitializer
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.providers.calendar
  adb -s tablet-$room.imagilan:5555 shell pm disable com.android.smspush
  adb -s tablet-$room.imagilan:5555 shell pm disable com.cyanogenmod.trebuchet
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.audiofx
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.eleven
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.jelly
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.lockclock
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.recorder
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.setupwizard
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.snap
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.terminal
  adb -s tablet-$room.imagilan:5555 shell pm disable org.lineageos.trebuchet
  #adb -s tablet-$room.imagilan:5555 shell pm uninstall org.openhab.habdroid.beta
}

function start_wakelock_app {
  echo "Starting the wakelock app once. Make sure it knows to start at boot"
  adb -s tablet-$room.imagilan:5555 shell am start -n eu.thedarken.wldonate/eu.thedarken.wldonate.main.ui.MainActivity
}

function set_wallpanel_as_launcher {
  echo "setting wallpanel as launcher"
  # Dumps the information about every activity that is shown in the launcher (i.e., has the launcher intent).
  # adb -s tablet-$room.imagilan:5555 shell "cmd package query-activities -a android.intent.action.MAIN -c android.intent.category.LAUNCHER"
  adb -s tablet-$room.imagilan:5555 shell am start -n xyz.wallpanel.app/.ui.activities.BrowserActivityNative
  adb -s tablet-$room.imagilan:5555 shell cmd package set-home-activity xyz.wallpanel.app/.ui.activities.BrowserActivityNative
}

function restart_tablet {
  adb -s tablet-$room.imagilan:5555 reboot &
  sleep 2
  adb -s tablet-$room.imagilan:5555 kill-server
}