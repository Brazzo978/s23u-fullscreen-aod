# S23 Ultra Fullscreen Wallpaper AOD

A systemless Magisk module that enables the S24-style fullscreen wallpaper Always On Display. It was developed and tested on the European Galaxy S23 Ultra; other Samsung devices are available for community testing.

> [!CAUTION]
> **Install and use this module entirely at your own risk.** The author and contributors are not responsible for a bricked device, boot loop, data loss, display damage, flicker, green flashes, burn-in, battery drain, or any other damage. The only configuration tested end-to-end is **SM-S918B (`dm3q`), Android 16 / One UI 8, build `S918BXXS8EZA1`, Magisk 30.7**.

## Quick install

1. [Download the stable Magisk module](https://github.com/Brazzo978/s23u-fullscreen-aod/releases/latest/download/S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.1.zip).
2. [Download the TWRP rescue ZIP](https://github.com/Brazzo978/s23u-fullscreen-aod/releases/latest/download/RESCUE-disable-S23U-AOD-module-TWRP-v2.zip) and keep it in storage accessible from recovery.
3. In Magisk, open **Modules > Install from storage** and select the stable module ZIP.
4. Read any compatibility warning, finish the installation, and reboot.
5. Enable AOD, select a compatible lock-screen wallpaper, and let AOD settle for at least 20 seconds.

> [!WARNING]
> Do **not** flash the Magisk module ZIP from TWRP. Only the separately named rescue ZIP is intended for TWRP.

### Upgrading from the withdrawn 1/10 Hz builds

If Magisk still shows version `2.0-10hz`, do **not** press its **Action** button: the old action script can send the withdrawn 10 Hz LFD command again. Install v2.1.1 over the existing module and reboot. Because the module ID is unchanged, the new installer automatically removes the old `service.sh`, `action.sh`, and `target_hz` files before installing the stable configuration.

Do not uninstall the old version first unless you specifically want to remove the feature; an in-place Magisk update performs the stale-file cleanup.

## Stable release

Only one build is distributed:

- `S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.1.zip`

The panel was verified at an effective 30 Hz while fullscreen AOD was visible. Experimental forced 1, 10, and 15 Hz modes were withdrawn because they produced visible flicker; some transitions also produced severe green flicker. Do not force those modes on this panel.

## The bug this fixes

Samsung's S23 firmware still contains the interface and much of the logic needed for fullscreen wallpaper AOD. Setting only `SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN=1` exposes the feature and renders the wallpaper, but the S23 product overlay does not provide the doze auto-brightness maps expected by this mode.

When AOD hands brightness control to the low-power doze path, that missing mapping leaves it without the correct target values. The wallpaper then becomes approximately 99% dimmed and appears almost completely black. This can look like a SystemUI dark overlay, but the firmware comparison showed that the missing product-overlay brightness resources were the important difference.

This module supplies only the missing S24 lux-to-nits arrays and lets the phone's own AODService, framework, display driver, and S23 calibration apply them. It does not install an S24 SystemUI or AODService APK.

A separate issue appeared when fullscreen AOD entered very low refresh-rate modes: forced 1, 10, and 15 Hz testing produced visible flicker and, during some transitions, severe green flashes. The stable release therefore selects Samsung's fixed AOD path, observed as 30 Hz on the tested S23 Ultra.

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

## Tested configuration

- Samsung Galaxy S23 Ultra `SM-S918B`, codename `dm3q`
- Android 16 / One UI 8 (`SDK 36`)
- Firmware `S918BXXS8EZA1`
- Magisk 30.7
- A fullscreen-compatible lock-screen wallpaper and AOD enabled

## Community testing on other Samsung devices

The installer allows other Samsung models, codenames, firmware builds, and API levels to continue after displaying a prominent warning. It rejects non-Samsung devices and aborts if the required floating-feature file or tags cannot be patched.

Galaxy S23, S23+, S22 Ultra, S22+, other S23 Ultra variants, and One UI 6/7 builds are **untested community-test targets**. They may work, do nothing, boot-loop, show a black AOD, flicker, produce panel artifacts, or use an unsuitable brightness curve. Samsung models use different panels, drivers, calibration data, and firmware logic, so compatibility with one Galaxy does not prove compatibility with another.

If you test another configuration, open an issue and include the exact model, codename, firmware/build, Android/API level, Magisk version, and observed AOD behavior.

## Before installing

- Use an unlocked Samsung device with Magisk.
- Back up important data.
- Keep the TWRP rescue ZIP in storage that recovery can access.
- Confirm that TWRP can decrypt or otherwise access `/data`.
- Remove or disable other AOD, display, refresh-rate, LFD, or floating-feature modules to avoid conflicts.
- Make sure you know how to disable a Magisk module from recovery.


## Installation

1. Copy `RESCUE-disable-S23U-AOD-module-TWRP-v2.zip` somewhere accessible from TWRP.
2. Open Magisk, choose **Modules > Install from storage**, and select `S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.1.zip`.
3. Check the detected model, codename, API level, and firmware shown by the installer. On an untested configuration, continuing means accepting all associated risk.
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
- Other Samsung devices and firmware are community-test targets only; compatibility is not claimed or implied.

## Checksums (v2.1.1)

```text
36A95C6C32F0FE0104BE7CD64298674BA9E0859B0B7726FE5F6057D3A41C59D4  S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.1.zip
F2BD84BE57412022EF2B8FD090D92F52A7693490D4931B1384059198FFCA529C  RESCUE-disable-S23U-AOD-module-TWRP-v2.zip
```

## Credits
Manu and Codex, for tracing the almost-black fullscreen AOD to the missing doze-brightness mappings and validating the required resources against S24 firmware.
