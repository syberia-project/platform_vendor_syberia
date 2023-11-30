# Add variables that we wish to make available to soong here.
PATH_OVERRIDE_SOONG := $(shell echo $(TOOLS_PATH_OVERRIDE))

EXPORT_TO_SOONG := \
    KERNEL_ARCH \
    KERNEL_BUILD_OUT_PREFIX \
    KERNEL_CROSS_COMPILE \
    KERNEL_MAKE_CMD \
    KERNEL_MAKE_FLAGS \
    PATH_OVERRIDE_SOONG \
    TARGET_KERNEL_CONFIG \
    TARGET_KERNEL_SOURCE

# Setup SOONG_CONFIG_* vars to export the vars listed above.
# Documentation here:
# https://github.com/LineageOS/android_build_soong/commit/8328367c44085b948c003116c0ed74a047237a69

SOONG_CONFIG_NAMESPACES += aospVarsPlugin

SOONG_CONFIG_aospVarsPlugin :=

define addVar
  SOONG_CONFIG_aospVarsPlugin += $(1)
  SOONG_CONFIG_aospVarsPlugin_$(1) := $$(subst ",\",$$($1))
endef

$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call addVar,$(v))))

SOONG_CONFIG_NAMESPACES += aospGlobalVars
SOONG_CONFIG_aospGlobalVars += \
    aapt_version_code \
    additional_gralloc_10_usage_bits \
    bootloader_message_offset \
    camera_needs_client_info \
    camera_needs_client_info_lib \
    camera_needs_client_info_lib_oplus \
    has_legacy_camera_hal1 \
    uses_oplus_camera \
    uses_nothing_camera \
    uses_oppo_camera \
    ignores_ftp_pptp_conntrack_failure \
    needs_netd_direct_connect_rule \
    camera_override_format_from_reserved \
    gralloc_handle_has_custom_content_md_reserved_size \
    gralloc_handle_has_reserved_size \
    target_init_vendor_lib \
    target_ld_shim_libs \
    target_process_sdk_version_override \
    target_surfaceflinger_udfps_lib \
    uses_camera_parameter_lib

SOONG_CONFIG_NAMESPACES += aospNvidiaVars
SOONG_CONFIG_aospNvidiaVars += \
    uses_nv_enhancements

SOONG_CONFIG_NAMESPACES += aospQcomVars
SOONG_CONFIG_aospQcomVars += \
    qti_vibrator_effect_lib \
    qti_vibrator_use_effect_stream \
    should_wait_for_qsee \
    supports_extended_compress_format \
    supports_hw_fde \
    supports_hw_fde_perf \
    uses_pre_uplink_features_netmgrd \
    uses_qcom_bsp_legacy \
    uses_qti_camera_device

SOONG_CONFIG_NAMESPACES += qtidisplaycommonsys
SOONG_CONFIG_qtidisplaycommonsys := displayextension composer3ext

# Only create display_headers_namespace var if dealing with UM platforms to avoid breaking build for all other platforms
ifneq ($(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
SOONG_CONFIG_aospQcomVars += \
    qcom_display_headers_namespace
endif

# Soong bool variables
SOONG_CONFIG_aospGlobalVars_aapt_version_code := $(shell date -u +%Y%m%d)
SOONG_CONFIG_aospGlobalVars_gralloc_handle_has_custom_content_md_reserved_size := $(TARGET_GRALLOC_HANDLE_HAS_CUSTOM_CONTENT_MD_RESERVED_SIZE)
SOONG_CONFIG_aospGlobalVars_gralloc_handle_has_reserved_size := $(TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE)
SOONG_CONFIG_aospGlobalVars_gralloc_handle_has_ubwcp_format := $(TARGET_GRALLOC_HANDLE_HAS_UBWCP_FORMAT)
SOONG_CONFIG_aospGlobalVars_camera_needs_client_info := $(TARGET_CAMERA_NEEDS_CLIENT_INFO)
SOONG_CONFIG_aospGlobalVars_camera_needs_client_info_lib := $(TARGET_CAMERA_NEEDS_CLIENT_INFO_LIB)
SOONG_CONFIG_aospGlobalVars_camera_needs_client_info_lib_oplus := $(TARGET_CAMERA_NEEDS_CLIENT_INFO_LIB_OPLUS)
SOONG_CONFIG_aospGlobalVars_has_legacy_camera_hal1 := $(TARGET_HAS_LEGACY_CAMERA_HAL1)
SOONG_CONFIG_aospGlobalVars_ignores_ftp_pptp_conntrack_failure := $(TARGET_IGNORES_FTP_PPTP_CONNTRACK_FAILURE)
SOONG_CONFIG_aospGlobalVars_needs_netd_direct_connect_rule := $(TARGET_NEEDS_NETD_DIRECT_CONNECT_RULE)
SOONG_CONFIG_aospNvidiaVars_uses_nv_enhancements := $(NV_ANDROID_FRAMEWORK_ENHANCEMENTS)
SOONG_CONFIG_aospQcomVars_qti_vibrator_use_effect_stream := $(TARGET_QTI_VIBRATOR_USE_EFFECT_STREAM)
SOONG_CONFIG_aospQcomVars_should_wait_for_qsee := $(TARGET_KEYMASTER_WAIT_FOR_QSEE)
SOONG_CONFIG_aospQcomVars_supports_extended_compress_format := $(AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT)
SOONG_CONFIG_aospQcomVars_supports_hw_fde := $(TARGET_HW_DISK_ENCRYPTION)
SOONG_CONFIG_aospQcomVars_supports_hw_fde_perf := $(TARGET_HW_DISK_ENCRYPTION_PERF)
SOONG_CONFIG_aospQcomVars_uses_pre_uplink_features_netmgrd := $(TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD)
SOONG_CONFIG_aospQcomVars_uses_qcom_bsp_legacy := $(TARGET_USES_QCOM_BSP_LEGACY)
SOONG_CONFIG_aospQcomVars_uses_qti_camera_device := $(TARGET_USES_QTI_CAMERA_DEVICE)
SOONG_CONFIG_aospGlobalVars_uses_oplus_camera := $(TARGET_USES_OPLUS_CAMERA)
SOONG_CONFIG_aospGlobalVars_uses_nothing_camera := $(TARGET_USES_NOTHING_CAMERA)
SOONG_CONFIG_aospGlobalVars_uses_oppo_camera := $(TARGET_USES_OPPO_CAMERA)
SOONG_CONFIG_aospGlobalVars_camera_override_format_from_reserved := $(TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED)

# Set default values
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED ?= false
TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE ?= false
TARGET_GRALLOC_HANDLE_HAS_CUSTOM_CONTENT_MD_RESERVED_SIZE ?= false
TARGET_INIT_VENDOR_LIB ?= vendor_init
TARGET_QTI_VIBRATOR_EFFECT_LIB ?= libqtivibratoreffect
TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY ?= libcamera_parameters
TARGET_SURFACEFLINGER_UDFPS_LIB ?= surfaceflinger_udfps_lib

# Soong value variables
SOONG_CONFIG_aospGlobalVars_additional_gralloc_10_usage_bits := $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS)
SOONG_CONFIG_aospGlobalVars_bootloader_message_offset := $(BOOTLOADER_MESSAGE_OFFSET)
SOONG_CONFIG_aospGlobalVars_target_init_vendor_lib := $(TARGET_INIT_VENDOR_LIB)
SOONG_CONFIG_aospGlobalVars_target_ld_shim_libs := $(subst $(space),:,$(TARGET_LD_SHIM_LIBS))
SOONG_CONFIG_aospGlobalVars_target_process_sdk_version_override := $(TARGET_PROCESS_SDK_VERSION_OVERRIDE)
SOONG_CONFIG_aospGlobalVars_target_surfaceflinger_udfps_lib := $(TARGET_SURFACEFLINGER_UDFPS_LIB)
SOONG_CONFIG_aospGlobalVars_uses_camera_parameter_lib := $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY)
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
SOONG_CONFIG_aospQcomVars_qcom_display_headers_namespace := vendor/qcom/opensource/commonsys-intf/display
else
SOONG_CONFIG_aospQcomVars_qcom_display_headers_namespace := $(QCOM_SOONG_NAMESPACE)/display
endif
SOONG_CONFIG_aospQcomVars_qti_vibrator_effect_lib := $(TARGET_QTI_VIBRATOR_EFFECT_LIB)
