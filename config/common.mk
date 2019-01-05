
ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google

else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
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
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/syberia/overlay/common \
    vendor/syberia/overlay/themes

BUILD_RRO_SYSTEM_PACKAGE := $(TOPDIR)vendor/syberia/build/core/system_rro.mk

# We modify several neverallows, so let the build proceed
ifneq ($(TARGET_BUILD_VARIANT),user)
SELINUX_IGNORE_NEVERALLOWS := true
endif

PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/sysinit:system/bin/sysinit


# Vendor specific init files
$(foreach f,$(wildcard vendor/syberia/prebuilt/common/etc/init/*.rc),\
    $(eval PRODUCT_COPY_FILES += $(f):system/etc/init/$(notdir $f)))

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/mkshrc:system/etc/mkshrc

# Init files
ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/backuptool_ab.sh:system/bin/backuptool_ab.sh \
    vendor/syberia/prebuilt/common/bin/backuptool_ab.functions:system/bin/backuptool_ab.functions \
    vendor/syberia/prebuilt/common/bin/backuptool_postinstall.sh:system/bin/backuptool_postinstall.sh
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/syberia/build/tools/50-syberia.sh:system/addon.d/50-syberia.sh \
    vendor/syberia/build/tools/backuptool.sh:install/bin/backuptool.sh \
    vendor/syberia/build/tools/backuptool.functions:install/bin/backuptool.functions \
    vendor/syberia/prebuilt/common/bin/clean_cache.sh:system/bin/clean_cache.sh
    
# Bootanimation
$(call inherit-product, vendor/syberia/config/bootanimation.mk)

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/syberia/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Default and google apps privapp permissions
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/privapp-permissions-syberia.xml:system/etc/permissions/privapp-permissions-syberia.xml \
    vendor/syberia/prebuilt/common/etc/privapp-permissions-googleapps.xml:system/etc/permissions/privapp-permissions-googleapps.xml \
    vendor/syberia/prebuilt/common/etc/privapp-permissions-turbo.xml:system/etc/permissions/privapp-permissions-turbo.xml

# Keyboard libs
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/lib64/libjni_latinimegoogle.so:system/lib64/libjni_latinimegoogle.so \
    vendor/syberia/prebuilt/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/syberia/overlay/dictionaries

#Google prebuilts
PRODUCT_PACKAGES += \
    MarkupGoogle \
    WallpaperPickerGoogle \
    WellbeingPrebuilt \
    Turbo

# Markup libs
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/lib64/libsketchology_native.so:system/lib64/libsketchology_native.so

#Sysconfig
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/sysconfig/pixel.xml:system/etc/sysconfig/pixel.xml \
    vendor/syberia/prebuilt/common/etc/sysconfig/turbo.xml:system/etc/sysconfig/turbo.xml

# Substratum Key
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/apk/SubstratumKey.apk:system/priv-app/SubstratumKey/SubstratumKey.apk

# Lawnchair
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/permissions/privapp-permissions-lawnchair.xml:system/etc/permissions/privapp-permissions-lawnchair.xml \
    vendor/syberia/prebuilt/common/etc/sysconfig/lawnchair-hiddenapi-package-whitelist.xml:system/etc/sysconfig/lawnchair-hiddenapi-package-whitelist.xml

# Packages
include vendor/syberia/config/packages.mk

# Inherit common product build prop overrides
-include vendor/syberia/config/versions.mk

# Inherit common syberia sepolicy
include device/syberia/sepolicy/common/sepolicy.mk

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
