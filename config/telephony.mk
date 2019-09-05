# Inherit common stuff
$(call inherit-product, vendor/syberia/config/common.mk)

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml

# World APN list
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/etc/apns-conf.xml:system/etc/apns-conf.xml

# World SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/syberia/prebuilt/etc/spn-conf.xml:system/etc/spn-conf.xml

# Telephony packages
PRODUCT_PACKAGES += \
    messaging \
    Stk \
    CellBroadcastReceiver