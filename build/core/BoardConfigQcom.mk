# Bring in Qualcomm helper macros
include vendor/syberia/build/core/qcom_utils.mk

B_FAMILY := msm8226 msm8610 msm8974
B64_FAMILY := msm8992 msm8994
BR_FAMILY := msm8909 msm8916
UM_3_18_FAMILY := msm8937 msm8953 msm8996
UM_4_4_FAMILY := msm8998 sdm660
UM_4_9_FAMILY := sdm845 sdm710
UM_4_14_FAMILY := sm8150 sm6150 $(TRINKET)
UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY)

BOARD_USES_ADRENO := true

#TARGET_USES_QCOM_BSP := true

# Tell HALs that we're compiling an AOSP build with an in-line kernel
TARGET_COMPILE_WITH_MSM_KERNEL := true

ifneq ($(filter msm7x27a msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
    # Enable legacy audio functions
    ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
        USE_CUSTOM_AUDIO_POLICY := 1
    endif
endif

# Allow building audio encoders
TARGET_USES_QCOM_MM_AUDIO := true

# Enable color metadata for UM platforms
ifeq ($(call is-board-platform-in-list, $(UM_PLATFORMS)),true)
    TARGET_USES_COLOR_METADATA := true
endif

# Mark GRALLOC_USAGE_PRIVATE_WFD as valid gralloc bits
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 21)

# Mark GRALLOC_USAGE_PRIVATE_10BIT_TP as valid gralloc bits on UM platforms that support it
ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY) $(UM_4_14_FAMILY)),true)
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 27)
endif

# Enable DRM PP driver on UM platforms that support it
ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY)),true)
    TARGET_USES_DRM_PP := true
endif

# List of targets that use master side content protection
MASTER_SIDE_CP_TARGET_LIST := msm8996 msm8998 sdm660 sm6150 sm8150 sdm845 $(TRINKET)
ifeq ($(call is-board-platform-in-list, $(B_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(B_FAMILY)
    QCOM_HARDWARE_VARIANT := msm8974
    TARGET_USES_QCOM_UM_FAMILY := true
    TARGET_USES_QCOM_UM_3_4_FAMILY := true
else ifeq ($(call is-board-platform-in-list, $(B64_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(B64_FAMILY)
    QCOM_HARDWARE_VARIANT := msm8994
else ifeq ($(call is-board-platform-in-list, $(BR_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(BR_FAMILY)
    QCOM_HARDWARE_VARIANT := msm8916
else ifeq ($(call is-board-platform-in-list, $(UM_3_18_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(UM_3_18_FAMILY)
    QCOM_HARDWARE_VARIANT := msm8996
    TARGET_USES_QCOM_UM_FAMILY := true
    TARGET_USES_QCOM_UM_3_18_FAMILY := true
else ifeq ($(call is-board-platform-in-list, $(UM_4_4_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(UM_4_4_FAMILY)
    QCOM_HARDWARE_VARIANT := msm8998
    TARGET_USES_QCOM_UM_FAMILY := true
    TARGET_USES_QCOM_UM_4_4_FAMILY := true
else ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(UM_4_9_FAMILY)
    QCOM_HARDWARE_VARIANT := sdm845
    TARGET_USES_QCOM_UM_FAMILY := true
    TARGET_USES_QCOM_UM_4_9_FAMILY := true
else ifeq ($(call is-board-platform-in-list, $(UM_4_14_FAMILY)),true)
    MSM_VIDC_TARGET_LIST := $(UM_4_14_FAMILY)
    QCOM_HARDWARE_VARIANT := sm8150
    TARGET_USES_QCOM_UM_FAMILY := true
    TARGET_USES_QCOM_UM_4_14_FAMILY := true
else
    MSM_VIDC_TARGET_LIST := $(TARGET_BOARD_PLATFORM)
    QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
endif

PRODUCT_SOONG_NAMESPACES += \
  hardware/qcom/audio-caf/$(QCOM_HARDWARE_VARIANT) \
  hardware/qcom/display-caf/$(QCOM_HARDWARE_VARIANT) \
  hardware/qcom/media-caf/$(QCOM_HARDWARE_VARIANT)

ifneq ($(TARGET_USES_PREBUILT_CAMERA_SERVICE), true)
PRODUCT_SOONG_NAMESPACES += \
    frameworks/av/camera/cameraserver \
    frameworks/av/services/camera/libcameraservice
endif

include vendor/syberia/build/core/BoardConfigKernel.mk
include vendor/syberia/build/core/BoardConfigSoong.mk