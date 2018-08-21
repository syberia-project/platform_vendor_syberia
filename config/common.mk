#Overlays
PRODUCT_PACKAGE_OVERLAYS += vendor/syberia/overlay/common

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

PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/bin/sysinit:system/bin/sysinit
    
# Init files
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/init.local.rc:system/etc/init/syberia.rc
    
# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/mkshrc:system/etc/mkshrc
    
# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/syberia/build/tools/50-syberia.sh:system/addon.d/50-syberia.sh \
    vendor/syberia/build/tools/backuptool.sh:install/bin/backuptool.sh \
    vendor/syberia/build/tools/backuptool.functions:install/bin/backuptool.functions \
    

# Keyboard libs
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/lib64/libjni_latinimegoogle.so:system/lib64/libjni_latinimegoogle.so \
    vendor/syberia/prebuilt/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so

PRODUCT_PACKAGES += \
    MarkupGoogle \
    WallpaperPickerGoogle \
    WellbeingPrebuilt

# Markup libs
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/lib/libsketchology_native.so:system/lib/libsketchology_native.so \
    vendor/syberia/prebuilt/common/lib64/libsketchology_native.so:system/lib64/libsketchology_native.so

# Pixel sysconfig
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/common/etc/sysconfig/pixel.xml:system/etc/sysconfig/pixel.xml

# Inherit common product build prop overrides
-include vendor/syberia/config/versions.mk
