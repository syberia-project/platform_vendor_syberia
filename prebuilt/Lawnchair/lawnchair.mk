# Lawnchair
LAWN_ROOT := vendor/syberia/prebuilt/Lawnchair

PRODUCT_PACKAGES += Lawnchair
PRODUCT_PACKAGE_OVERLAYS += $(LAWN_ROOT)/overlay
PRODUCT_COPY_FILES += \
    $(LAWN_ROOT)/permissions/privapp-permissions-lawnchair.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-lawnchair.xml \
    $(LAWN_ROOT)/sysconfig/lawnchair-hiddenapi-package-whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/lawnchair-hiddenapi-package-whitelist.xml
