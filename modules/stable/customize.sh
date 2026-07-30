#!/system/bin/sh

ui_print "- Checking device and firmware"
MODEL="$(getprop ro.product.model)"
DEVICE="$(getprop ro.product.device)"
SDK="$(getprop ro.build.version.sdk)"
BUILD="$(getprop ro.build.PDA)"
MANUFACTURER="$(getprop ro.product.manufacturer)"
BRAND="$(getprop ro.product.brand)"

if [ "$MANUFACTURER" != "samsung" ] && [ "$BRAND" != "samsung" ]; then
  abort "! Refusing install: this module is only intended for Samsung devices"
fi

ui_print "- Detected: $MODEL / $DEVICE / SDK $SDK"
ui_print "- Firmware: $BUILD"

if [ "$MODEL" != "SM-S918B" ] || [ "$DEVICE" != "dm3q" ] || [ "$SDK" != "36" ] || [ "$BUILD" != "S918BXXS8EZA1" ]; then
  ui_print "!"
  ui_print "! WARNING: UNTESTED DEVICE OR FIRMWARE"
  ui_print "! Tested only on SM-S918B / dm3q / SDK 36"
  ui_print "! Build S918BXXS8EZA1 with Magisk 30.7"
  ui_print "! Display behavior differs between Samsung models."
  ui_print "! Boot loops, black AOD, flicker, panel artifacts,"
  ui_print "! burn-in, or data loss are possible."
  ui_print "! Continuing means you accept all responsibility."
  ui_print "! Keep the TWRP rescue ZIP accessible before reboot."
  ui_print "!"
  sleep 5
fi
SOURCE_FF="/system/etc/floating_feature.xml"
DEST_FF="$MODPATH/system/etc/floating_feature.xml"

# This release has no refresh-rate daemon or Magisk action button.
# Remove files left by the previous experimental 1/10 Hz builds if the
# installer happens to reuse the module directory.
rm -f "$MODPATH/service.sh" "$MODPATH/action.sh" "$MODPATH/target_hz"

if [ ! -r "$SOURCE_FF" ]; then
  abort "! Cannot read $SOURCE_FF"
fi

mkdir -p "$MODPATH/system/etc"
cp -af "$SOURCE_FF" "$DEST_FF" || abort "! Failed to copy floating_feature.xml"

sed -i \
  -e 's#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>[^<]*</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>0</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>#' \
  -e 's#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>[^<]*</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>1</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>#' \
  -e 's#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>[^<]*</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>#<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>0</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>#' \
  "$DEST_FF" || abort "! Failed to patch floating_feature.xml"

grep -q '<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>0</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION>' "$DEST_FF" || abort "! Brightness animation tag not found"
grep -q '<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>1</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN>' "$DEST_FF" || abort "! Fullscreen AOD tag not found"
grep -q '<SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>0</SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE>' "$DEST_FF" || abort "! AOD refresh-rate tag not found"

ui_print "- Installing fullscreen AOD and S24 doze maps"
ui_print "- Selecting Samsung's fixed AOD refresh path (30 Hz observed)"
ui_print "- No background LFD controller or Action command is installed"
set_perm_recursive "$MODPATH/system" 0 0 0755 0644
