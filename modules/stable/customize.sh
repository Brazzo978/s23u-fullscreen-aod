#!/system/bin/sh

ui_print "- Checking supported device and firmware"
MODEL="$(getprop ro.product.model)"
DEVICE="$(getprop ro.product.device)"
SDK="$(getprop ro.build.version.sdk)"
BUILD="$(getprop ro.build.PDA)"

if [ "$MODEL" != "SM-S918B" ] || [ "$DEVICE" != "dm3q" ] || [ "$SDK" != "36" ]; then
  abort "! Refusing install: expected SM-S918B / dm3q / SDK 36, got $MODEL / $DEVICE / SDK $SDK"
fi

ui_print "- Firmware: $BUILD"
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
