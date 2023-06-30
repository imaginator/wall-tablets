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

Builds from https://github.com/mt8163-dev/android_device_amazon_douglas/releases

1. adb put lineage-17.1-20230520-UNOFFICIAL-douglas.zip
2. boot into twrp (power+volume down), flash the zip
3. enable developer options, enable usb debugging
4. run `ẁallpanel-setup.sh <room-name>` # or other rooms

