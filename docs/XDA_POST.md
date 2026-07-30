# XDA post draft

## [MAGISK][SM-S918B][ONE UI 8] S24-style fullscreen wallpaper AOD - stable 30 Hz path

I have been testing the S24-style fullscreen wallpaper AOD on the Galaxy S23 Ultra. Enabling only Samsung's floating feature exposes the interface, but current One UI 8 builds can leave the fullscreen AOD almost black. The normal low-frequency AOD path also produced flicker after the device entered deep doze with a fullscreen image.

This module enables fullscreen AOD, supplies the missing doze-brightness map, and selects the stable Samsung AOD path without replacing SystemUI or AODService.

### Tested configuration

- Device: Galaxy S23 Ultra `SM-S918B` (`dm3q`)
- Firmware: `S918BXXS8EZA1`
- OS: Android 16 / One UI 8 / SDK 36
- Root: Magisk 30.7
- SELinux: Enforcing

Other builds and models are untested. The installer rejects a different model, codename, or API level.

### What the module does

1. Sets `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN=1`.
2. Sets `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION=0`.
3. Sets `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE=0`.
4. Adds the S24 doze auto-brightness lux/nits arrays missing from the S23 product overlay.

The refresh-rate value is a Samsung feature selector, not a literal frequency. On the tested firmware, value `0` selects AODService's `fix=1` path and the panel reports an effective stable 30 Hz.

The module contains no background service, Action script, polling loop, or direct LFD command. Forced 1, 10, and 15 Hz experiments were withdrawn because sustained fullscreen operation flickered; some transitions produced severe green flicker.

### Safety design

- No SystemUI APK replacement
- No AODService APK replacement
- No kernel modification
- No `setenforce 0`
- No custom SELinux policy
- No background root daemon
- Systemless Magisk mount
- Exact model/codename/API checks
- Installation aborts if expected floating-feature tags are absent
- Separate TWRP rescue ZIP disables the module

This cannot guarantee zero risk. Root modifications and unsupported display features can always cause boot or UI problems. Back up important data first.

### Installation

1. Download the stable module and rescue ZIP.
2. Keep the rescue ZIP accessible from TWRP.
3. Install `S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.0.zip` through Magisk.
4. Reboot.
5. Enable AOD and select a compatible lock-screen wallpaper.
6. Wait at least 20 seconds after AOD appears and confirm there is no flicker.

### Verify the active panel mode

With AOD visible:

```sh
adb shell su -c "cat /sys/class/lcd/panel/vrr_lfd"
```

Expected effective result:

```text
client=aod scope=lpm fix=1
scope=lpm: LFD freq: 30.0hz ~ 30.0hz, div: 1 ~ 1
```

Do not read unrelated panel sysfs nodes; some perform active hardware tests.

### Emergency disable

From booted Android with root ADB:

```sh
adb shell su -c "touch /data/adb/modules/s23u_aod_patch/disable"
adb reboot
```

If Android cannot boot, flash the included rescue ZIP from TWRP. Recovery must be able to access `/data`.

### Bug reports

Please include the exact model, `ro.build.PDA`, Magisk version, whether flicker begins immediately or after deep doze, and the known-safe `/sys/class/lcd/panel/vrr_lfd` output while AOD is visible.

### Downloads

- `S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.0.zip`
