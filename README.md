Amazon Fire HD8 (2018) (douglas)
================================

```
douglas:/ # cat /proc/cpuinfo                                                                                                                                                               
Processor       : AArch64 Processor rev 3 (aarch64)
processor       : 0
model name      : AArch64 Processor rev 3 (aarch64)
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 3

Hardware        : MT8163
Revision        : 0032 0040
Serial          : b01ecb162df35158
```


1. pull builds from https://github.com/mt8163-dev/android_device_amazon_douglas/releases
2. `adb push lineage-17.1-20230520-UNOFFICIAL-douglas.zip /sdcard/`
3. adb reboot recovery
4. flash the zip
5. enable developer options, enable remote debugging
6. 
```
adb connect <tablet>
adb shell setprop persist.adb.tcp.port 5555 # keep adb via wifi enabled
adb push  ~/Documents/src/wall-tablets/templates/fully-auto-settings.json /sdcard
adb install Fully-Kiosk-Browser-v1.50.4-emm.apk
adb shell dpm set-device-owner com.fullykiosk.emm/de.ozerov.fully.DeviceOwnerReceiver
```
7. Start Fully Kiosk app and enter provisioning code `FFF` when asked
8. import the settings file from /sdcard


Other useful commands:

Break glass option
```
adb shell "am broadcast -a android.intent.action.MASTER_CLEAR"
```
