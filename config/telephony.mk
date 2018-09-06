# Inherit common stuff
$(call inherit-product, vendor/syberia/config/common.mk)

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/etc/selective-spn-conf.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/selective-spn-conf.xml

# World APN list
PRODUCT_PACKAGES += \
    apns-conf.xml

# World SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/etc/spn-conf.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/spn-conf.xml

# Telephony packages
PRODUCT_PACKAGES += \
    messaging \
    Stk \
    CellBroadcastReceiver