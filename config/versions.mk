# Versioning System
SYBERIA_VERSION = v1.0

ifndef SYBERIA_BUILD_TYPE
    SYBERIA_BUILD_TYPE := OFFICIAL
endif

# Set all versions
DATE := $(shell date -u +%Y%m%d)
SYBERIA_VERSION := $(TARGET_PRODUCT)-$(SYBERIA_VERSION)-$(DATE)-$(shell date -u +%H%M)-$(SYBERIA_BUILD_TYPE)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    ro.syberia.version=$(SYBERIA_VERSION) \
    ro.mod.version=$(SYBERIA_BUILD_TYPE)-$(SYBERIA_VERSION)-$(DATE)
