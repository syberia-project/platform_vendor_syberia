# Versioning System
SYBERIA_VERSION = v5.4
CUSTOM_PLATFORM_RELEASE_OR_CODENAME := 12L

ifndef SYBERIA_BUILD_TYPE
    SYBERIA_BUILD_TYPE := UNOFFICIAL
endif

# Set all versions
SYBERIA_DATE := $(shell date -u +%Y%m%d-%H%M)
TARGET_BACON_NAME := $(TARGET_PRODUCT)-$(SYBERIA_VERSION)-$(SYBERIA_DATE)-$(SYBERIA_BUILD_TYPE)
SYBERIA_FINGERPRINT := Syberia/$(SYBERIA_VERSION)/$(PLATFORM_VERSION)/$(BUILD_ID)/$(SYBERIA_DATE)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    ro.syberia.version=$(SYBERIA_VERSION) \
    com.syberia.fingerpring=$(SYBERIA_FINGERPRINT) \
    ro.syberia.display.version=Syberia-$(SYBERIA_VERSION) \
    ro.syberia.releasetype=$(SYBERIA_BUILD_TYPE) \
    ro.modversion=$(TARGET_BACON_NAME) \
    ro.syberia.settings.android_version=$(CUSTOM_PLATFORM_RELEASE_OR_CODENAME)
