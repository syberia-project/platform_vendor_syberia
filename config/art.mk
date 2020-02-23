# Don't build debug for host or device
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
ART_BUILD_TARGET_NDEBUG := true
ART_BUILD_TARGET_DEBUG := false
ART_BUILD_HOST_NDEBUG := true
ART_BUILD_HOST_DEBUG := false
USE_DEX2OAT_DEBUG := false

# Dex pre-opt
WITH_DEXPREOPT := true
WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false
PRODUCT_DEX_PREOPT_PROFILE_DIR := vendor/dexopt_profiles
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed-profile

# Boot image profile
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/config/boot-image-profile.txt

# System server compiler
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Speed apps
PRODUCT_DEXPREOPT_SPEED_APPS += \
  SystemUI \
  Settings

# Dexopt boot types
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    pm.dexopt.first-boot=extract \
    pm.dexopt.boot=verify

# Dexopt filters
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.shared=speed
    
# dex2oat threads (default)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.dex2oat-threads=8 \
    dalvik.vm.boot-dex2oat-threads=8