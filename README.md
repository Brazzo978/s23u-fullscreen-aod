# S23 Ultra Fullscreen Wallpaper AOD

A systemless Magisk module that enables the S24-style fullscreen wallpaper Always On Display on the European Galaxy S23 Ultra and supplies the doze-brightness resources missing from its One UI 8 product overlay.

> [!CAUTION]
> This is an experimental, device-specific modification. The only configuration tested end-to-end is **SM-S918B (`dm3q`), Android 16 / One UI 8, build `S918BXXS8EZA1`, Magisk 30.7**. Keep the rescue ZIP available before rebooting.

## Stable release

Only one build is distributed:

- `S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.0.zip`

The panel was verified at an effective 30 Hz while fullscreen AOD was visible. Experimental forced 1, 10, and 15 Hz modes were withdrawn because they produced visible flicker; some transitions also produced severe green flicker. Do not force those modes on this panel.

## What it changes

During installation the module copies the device's own `/system/etc/floating_feature.xml` and changes only:

- `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN=1`
- `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION=0`
- `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE=0`

`AOD_REFRESH_RATE=0` is a Samsung feature selector, not a request for 0 Hz. On the tested firmware it makes AODService select its fixed `fix=1` path, observed as a stable 30 Hz panel drive.

The module also adds a static resource overlay containing the missing S24 doze auto-brightness maps:

- Lux thresholds: `1, 10, 30, 50, 100, 500, 1000, 2000, 3000`
- Target nits: `2, 5, 10, 55, 64, 82, 139, 198, 331, 490`

Samsung still converts those target nits through the S23 Ultra's own display calibration and applies its brightness limits.

The stable module does not replace SystemUI or AODService, patch the kernel, add SELinux rules, or disable SELinux.
## Firmware cross-checks

The module was derived and checked against Samsung AP firmware; no foreign firmware component is included or flashed.

- S23 Ultra: `S918BXXS8EZA1` (Android 16 / One UI 8)
- S24 Ultra: `S928BXXS4CZA1` (Android 16 / One UI 8)
- Snapdragon S24+: `S926U1UES5CZD2` (Android 16 / One UI 8)

Panel command tables are intentionally not ported. The S23 Ultra firmware targets `S6E3HAE / AMB681AZ01`; the S24+ targets different `S6E3FAC / AMB655AY01` and `S6E3HAF / AMB666FM01` panels with different HLPM/LFD register sequences. Those files are hardware-specific and unsafe to reuse.

## Requirements

- Samsung Galaxy S23 Ultra `SM-S918B`, codename `dm3q`
- Android 16 / One UI 8 (`SDK 36`) (should work on one ui 7 and 6 too ) 
- Unlocked bootloader and Magisk
- A fullscreen-compatible lock-screen wallpaper and AOD enabled


## Installation

1. Copy `RESCUE-disable-S23U-AOD-module-TWRP-v2.zip` somewhere accessible from TWRP.
2. Open Magisk, choose **Modules > Install from storage**, and select the stable ZIP.
3. Verify that the installer finishes successfully.
4. Reboot.
5. Let AOD settle for at least 20 seconds and check that the wallpaper remains stable.

## Verification

With AOD visible, the following known-safe diagnostic was used:

```sh
adb shell su -c "cat /sys/class/lcd/panel/vrr_lfd"
```

The effective result should include:

```text
client=aod scope=lpm fix=1
scope=lpm: LFD freq: 30.0hz ~ 30.0hz, div: 1 ~ 1
```

Old `min` or `max` fields can remain in the driver's status after earlier experiments; the active `fix=1` line and effective LFD frequency are authoritative.

Do not probe unrelated panel sysfs nodes. Some apparently readable nodes perform active hardware tests rather than passive diagnostics.

## Recovery and removal

If Android boots and root ADB works:

```sh
adb shell su -c "touch /data/adb/modules/s23u_aod_patch/disable"
adb reboot
```

If Android cannot boot, flash `RESCUE-disable-S23U-AOD-module-TWRP-v2.zip` from TWRP and reboot. TWRP must be able to access `/data`.

To uninstall normally, remove **S23 Ultra Fullscreen AOD (30 Hz Stable)** in Magisk and reboot.

## Known limitations

- Samsung does not officially expose fullscreen wallpaper AOD on the S23 Ultra.
- The 30 Hz fixed path uses more display power than a genuine stable 1 Hz path would.
- Fullscreen OLED content can increase power use and wear. Prefer a dim wallpaper and keep Samsung's normal clock-position movement enabled.
- Firmware updates can change the resources and display behavior; reinstall only after confirming compatibility.
- No claims are made for other S23 Ultra variants or other models.

## Checksums (v2.1.0)

```text
FB6A1BC07D84A391D7587792F02BD35A7F1295553E46C59F6BD36D303177399F  S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.0.zip
F2BD84BE57412022EF2B8FD090D92F52A7693490D4931B1384059198FFCA529C  RESCUE-disable-S23U-AOD-module-TWRP-v2.zip
```

## Credits
Me & Codex for discovering that the mappings were not there so needed to port them from s24 to make it work (dim screen bug with only floating feature)
