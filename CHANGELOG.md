# Changelog

## 2.1.0 - 2026-07-30

- Made Samsung's fixed AOD refresh path (`fix=1`, effective 30 Hz on the tested panel) the only supported release.
- Removed the background LFD controller, Magisk Action command, and `target_hz` configuration.
- Added defensive cleanup of controller files left by experimental module versions.
- Withdrew the 1 Hz and 10 Hz packages after sustained low-frequency testing produced panel flicker.
- Kept SELinux Enforcing and retained the systemless floating-feature and resource-overlay design.
- Retained the S24 doze lux/nits map while preserving the S23 Ultra's own nits-to-brightness conversion and limits.
- Cross-checked the same doze map and AODService logic against Snapdragon S24+ build `S926U1UES5CZD2`; no hardware-specific panel tables are included.

## 2.0 - withdrawn experimental builds

- Tested persistent 1 Hz and 10 Hz LFD controllers through Samsung `AODManagerService`.
- These builds are not released because 1, 10, and 15 Hz operation was not visually stable with fullscreen AOD.

## 1.2 - internal test

- Disabled AOD brightness animation.
- Used Samsung's stable 30 Hz fallback.

## 1.0-1.1 - internal tests

- Added the fullscreen AOD feature flag.
- Added the missing S24 doze lux/nits maps.
