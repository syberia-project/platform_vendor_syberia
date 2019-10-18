# Don't build debug for host or device
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
ART_BUILD_TARGET_NDEBUG := true
ART_BUILD_TARGET_DEBUG := false
ART_BUILD_HOST_NDEBUG := true
ART_BUILD_HOST_DEBUG := false

# Dex pre-opt
WITH_DEXPREOPT := true
WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false
PRODUCT_DEX_PREOPT_PROFILE_DIR := vendor/dexopt_profiles
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed-profile

# Preopt apks like GMS chimara modules
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true

# Create profile for boot image
# Outputs to /system/etc/boot-image.prof
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true

# Speed apps
PRODUCT_DEXPREOPT_SPEED_APPS += \
  SystemUI \
  Settings

# Dex pre-opt profiles
WITH_DEX_PREOPT_GENERATE_PROFILE := true
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed-profile
PRODUCT_DEX_PREOPT_PROFILE_DIR := vendor/dexopt-profiles
