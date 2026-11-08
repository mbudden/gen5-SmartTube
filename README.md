# SmartTube for Gen5W head units

[SmartTube](https://github.com/yuliskov/SmartTube), patched to run on Hyundai/Kia/Genesis Gen5W head units (Android 4.4.2, Telechips), as a [NEMESIS](https://github.com/xwtk/hmg_nemesis) package.

> **One USB stick installs everything.** SmartTube needs the `media.codecs` package from [gen5-codec-patch](https://github.com/KramerTech/gen5-codec-patch), version 2.1 or newer: without it, SmartTube's player can't query the unit's video decoders and nothing plays. The USB download includes it and installs it first, then SmartTube, after a single prompt.

## What's different from upstream SmartTube

- **It runs on Gen5W.** Upstream's APK crashes on the splash screen and can't load anything on these units. This build fixes both.
- **Swipe in from the left edge of the screen to go back,** including out of the video player. Gen5W has no Back button for apps like this one.
- **It only uses Wi-Fi or a Bluetooth/USB hotspot, never the car's built-in modem.** The car's own connection isn't meant for streaming, and using it for that could get the car's connected services restricted. With no Wi-Fi or hotspot, SmartTube just can't connect. The rule is applied a few seconds after install and at every boot; its log is `/data/nemesis/logs/smarttube/netguard.log`.
- **No park-only lockout.** Upstream gen5-SmartTube closes when the car leaves park; this fork leaves that patch out.

## Install

You need NEMESIS 1.16 or newer.

Each release has two zips:

- **USB (one tap):** extract `smarttube-<version>-usb.zip` onto the root of a FAT32 or exFAT drive, so the drive holds `NEMESIS.data`, `install.sh` and `packages/`. Keep only one NEMESIS package on the drive. With the head unit fully booted, plug the drive in and confirm the prompt. It installs the video codec fix (`media.codecs` 2.1, skipped if you already have 2.1 or newer), then SmartTube, showing a message for each step, and NEMESIS reports success or failure at the end. An existing SmartTube is updated in place, so its settings and sign-in are kept. A log is written to `smarttube-install.log` on the drive.
- **ADB:** use `smarttube-<version>.zip`, the package itself, after installing `media.codecs` 2.1+ from [gen5-codec-patch releases](https://github.com/KramerTech/gen5-codec-patch/releases). Don't extract this one onto a USB drive: NEMESIS will report "Invalid package descriptor".
  ```sh
  adb push media.codecs-2.1.zip smarttube-<version>.zip /data/local/tmp/
  adb shell '/system/xbin/nemesis install --update /data/local/tmp/media.codecs-2.1.zip'
  adb shell '/system/xbin/nemesis install --update /data/local/tmp/smarttube-<version>.zip'
  ```

Launch it from NEMESIS Manager → My Packages → SmartTube, or from any launcher.

**Updating:** install the new release the same way. Both the USB stick and ADB with `--update` keep your SmartTube settings and sign-in. SmartTube may tell you when a new version is out, but install it as a NEMESIS package; updating from inside the app won't work on Gen5W.

If SmartTube was installed before from somewhere else (an upstream APK, or someone else's build), NEMESIS has to uninstall it first, which also resets its settings and sign-in.

## Uninstalling

Manager → My Packages → SmartTube → Uninstall, or `nemesis uninstall smarttube`. This removes SmartTube completely. NEMESIS won't uninstall `media.codecs` while SmartTube is installed, so uninstall SmartTube first if you want to remove both.

## License

The patch tooling and scripts in this repo are MIT-licensed ([`LICENSE`](LICENSE)). SmartTube itself is MIT-licensed by its author (`notices/SmartTube-LICENSE.txt`). The package ships that license and `notices/NOTICE.txt`, which lists the modifications. The USB zip also carries the unmodified `media.codecs` release zip from [gen5-codec-patch](https://github.com/KramerTech/gen5-codec-patch) (MIT scripts; its bundled decoder libraries are Apache 2.0 and BSD, with their notices inside that zip).
