# Inherit common stuff
$(call inherit-product, vendor/syberia/config/common.mk)

# Enable tethering
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.dun.override=0