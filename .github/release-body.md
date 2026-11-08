SmartTube @VERSION@, patched for Gen5W head units (Android 4.4), as a NEMESIS package.

**One USB stick installs everything:** extract `@USBZIP@` onto the root of a FAT32/exFAT drive, plug it in with the head unit booted, and confirm the prompt. It installs the video codec fix ([gen5-codec-patch](https://github.com/KramerTech/gen5-codec-patch) `media.codecs`, needed for playback) if you don't already have @CODECS_MIN_VERSION@+, then SmartTube. Needs NEMESIS 1.16 or newer.
@CHANGES@
What's different from upstream SmartTube (details in the README):
- Runs on Gen5W: upstream's APK crashes on the splash screen and can't load anything on these units.
- Swipe in from the left edge of the screen to go back, including out of the video player.
- Only uses Wi-Fi or a Bluetooth/USB hotspot, never the car's built-in modem.
- Park-only lockout removed in this fork: it keeps playing when the car is out of park.

Over ADB, install `media.codecs` @CODECS_MIN_VERSION@+ first, then `nemesis install --update @ZIP@`. Both ways keep an existing SmartTube's settings and sign-in. Check downloads against `SHA256SUMS`. If SmartTube was previously installed from another source with a different signing key, it gets reinstalled, which resets its settings and sign-in.

Built by GitHub Actions from upstream's [@UPSTREAM_TAG@](https://github.com/yuliskov/SmartTube/releases/tag/@UPSTREAM_TAG@) release (verified against GitHub's SHA-256 for the APK).
