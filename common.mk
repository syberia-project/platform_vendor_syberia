# Inherit common AOSP stuff
$(call inherit-product, vendor/syberia/config/common.mk)

$(call inherit-product, vendor/syberia/config/telephony.mk)

$(call inherit-product, vendor/syberia/config/syberia_props.mk)
