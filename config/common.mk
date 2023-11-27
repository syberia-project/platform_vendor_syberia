#Syberia OS
#
# Inherit art options
include vendor/syberia/config/art.mk

# ART
# Optimize everything for preopt
#PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := everything

ifeq ($(TARGET_SUPPORTS_64_BIT_APPS), true)
# Don't preopt prebuilts
DONT_DEXPREOPT_PREBUILTS := true

# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true
endif

PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.boot=verify \
    pm.dexopt.first-boot=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=everything

ifneq ($(AB_OTA_PARTITIONS),)
PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.ab-ota=verify
endif

# General additions
PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    dalvik.vm.debug.alloc=0 \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dataroaming=false \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.com.android.dateformat=MM-dd-yyyy \
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0 \
    ro.setupwizard.rotation_locked=true \
    ro.build.selinux=1

#ADB
PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    ro.secure=0 \
    persist.service.adb.enable=1

# Overlays
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/syberia/overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/syberia/overlay/common

# We modify several neverallows, so let the build proceed
ifneq ($(TARGET_BUILD_VARIANT),eng)
SELINUX_IGNORE_NEVERALLOWS := true
endif

PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/sysinit:$(TARGET_COPY_OUT_SYSTEM)/bin/sysinit


# Vendor specific init files
$(foreach f,$(wildcard vendor/syberia/prebuilt/common/etc/init/*.rc),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Init files
ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/syberia/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/syberia/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/syberia/build/tools/50-syberia.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-syberia.sh \
    vendor/syberia/build/tools/backuptool.sh:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.sh \
    vendor/syberia/build/tools/backuptool.functions:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.functions \
    vendor/syberia/prebuilt/common/bin/clean_cache.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/clean_cache.sh

# system mount
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/system-mount.sh:install/bin/system-mount.sh

# Disable async MTE on system_server
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.system_server=off

# Bootanimation
$(call inherit-product, vendor/syberia/config/bootanimation.mk)

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/syberia/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

PRODUCT_COPY_FILES += \
    vendor/syberia/config/permissions/privapp-permissions-syberia.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-syberia.xml \
    vendor/syberia/config/permissions/privapp-permissions-custom.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-custom.xml

# Fonts
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/syberia/prebuilt/fonts,$(TARGET_COPY_OUT_SYSTEM)/fonts) \
    vendor/syberia/prebuilt/etc/fonts_customization.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/fonts_customization.xml

include vendor/syberia/config/packages.mk

# Plugins
#include packages/apps/Plugins/plugins.mk

#ifneq ($(TARGET_WANTS_AOSP_LAUNCHER), true)
#-include vendor/syberia/prebuilt/Lawnchair/lawnchair.mk
#endif

# Inherit common product build prop overrides
-include vendor/syberia/config/versions.mk

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Dedupe VNDK libraries with identical core variants
TARGET_VNDK_USE_CORE_VARIANT := true

# Use a generic profile based boot image by default
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := art/build/boot/boot-image-profile.txt

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Don't compile SystemUITests
EXCLUDE_SYSTEMUI_TESTS := true

# IORap app launch prefetching using Perfetto traces and madvise
PRODUCT_PRODUCT_PROPERTIES += \
    ro.iorapd.enable=true

PRODUCT_SYSTEM_PROPERTIES += \
    persist.device_config.runtime_native_boot.iorap_perfetto_enable=true

# Disable touch video heatmap to reduce latency, motion jitter, and CPU usage
# on supported devices with Deep Press input classifier HALs and models
PRODUCT_PRODUCT_PROPERTIES += \
    ro.input.video_enabled=false

# Pixel charger animation
ifeq ($(TARGET_INCLUDE_PIXEL_CHARGER),true)
PRODUCT_PACKAGES += \
    product_charger_res_images
endif

ifeq ($(TARGET_SUPPORTS_64_BIT_APPS),true)
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif
