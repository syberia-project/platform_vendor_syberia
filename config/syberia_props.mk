PRODUCT_GENERIC_PROPERTIES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.mode=OPTIONAL \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.setupwizard.rotation_locked=true \
    ro.opa.eligible_device=true\
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0 \
    ro.build.selinux=0 \
    persist.sys.dun.override=0 \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so \
    ro.storage_manager.enabled=true \
    ro.substratum.verified=true \
    persist.sys.recovery_update=false \
    ro.com.google.ime.theme_id=5 \
    persist.sys.disable_rescue=true \
    ro.control_privapp_permissions=disable

# Disable HDCP check
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.wfd.nohdcp=1

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# GMS spoofing fingerprint
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.build.gms_fingerprint=google/angler/angler:6.0/MDB08L/2343525:user/release-keys

# Set cache location
ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/data/cache
else
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/cache
endif