add_json_str_omitempty = $(if $(strip $(2)),$(call add_json_str, $(1), $(2)))

_json_contents := $(_json_contents)    "Syberia":{$(newline)

$(call add_json_str_omitempty, Additional_gralloc_10_usage_bits, $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))
$(call add_json_bool,	Has_legacy_camera_hal1,				$(filter true,$(TARGET_HAS_LEGACY_CAMERA_HAL1)))
$(call add_json_str, 	Java_Source_Overlays, 				$(filter true,$(JAVA_SOURCE_OVERLAYS)))
$(call add_json_bool,	Needs_legacy_camera_hal1_dyn_native_handle,	$(filter true,$(TARGET_NEEDS_LEGACY_CAMERA_HAL1_DYN_NATIVE_HANDLE)))
$(call add_json_bool,	Uses_media_extensions,				$(filter true,$(TARGET_USES_MEDIA_EXTENSIONS)))
$(call add_json_bool,	Uses_generic_camera_parameter_library,		$(if $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY),,true))
$(call add_json_bool,	Needs_text_relocations,				$(filter true,$(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS)))
$(call add_json_bool,	Mtk_hardware,					$(filter true,$(BOARD_USES_MTK_HARDWARE)))
$(call add_json_bool,	BoardUsesQTIHardware,				$(filter true,$(BOARD_USES_QTI_HARDWARE)))
$(call add_json_bool,	Cant_reallocate_omx_buffers,			$(filter true,$(if $(filter omap4,$(TARGET_BOARD_PLATFORM)),true,false)))
$(call add_json_bool,	Qcom_bsp_legacy,				$(filter true,$(TARGET_USES_QCOM_BSP_LEGACY)))
$(call add_json_bool,	Qti_flac_decoder,				$(filter true,$(AUDIO_FEATURE_ENABLED_EXTN_FLAC_DECODER)))
$(call add_json_bool,	TargetUsesProprietaryLibs,			$(filter true,$(TARGET_USES_PROPRIETARY_LIBS)))
$(call add_json_bool,	Target_uses_qsml,				$(filter true,$(TARGET_USES_QSML)))
$(call add_json_bool,	Target_uses_eigen,				$(filter true,$(if $(strip $(TARGET_USES_QSML)),false,true)))
$(call add_json_bool,	Target_use_sdclang,				$(filter true,$(TARGET_USE_SDCLANG)))
$(call add_json_str_omitempty,	Additional_gralloc_10_usage_bits,	$(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))

$(call add_json_str,	Specific_camera_parameter_library,		$(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY))
$(call add_json_str,	Libart_img_base,				$(LIBART_IMG_BASE))
$(call add_json_str,	QTIAudioPath,					$(call project-path-for,qcom-audio))
$(call add_json_str,	QTIDisplayPath,					$(call project-path-for,qcom-display))
$(call add_json_str,	QTIMediaPath,					$(call project-path-for,qcom-media))
$(call add_json_str,	Target_shim_libs,				$(subst $(space),:,$(TARGET_LD_SHIM_LIBS)))
$(call add_json_str_omitempty, Target_surfaceflinger_fod_lib,           $(TARGET_SURFACEFLINGER_FOD_LIB))
$(call add_json_bool, 	Uses_qcom_um_family, 				$(filter true,$(TARGET_USES_QCOM_UM_FAMILY)))
$(call add_json_bool, 	Uses_qcom_um_3_4_family, 			$(filter true,$(TARGET_USES_QCOM_UM_3_4_FAMILY)))
$(call add_json_bool, 	Uses_qcom_um_3_18_family, 			$(filter true,$(TARGET_USES_QCOM_UM_3_18_FAMILY)))
$(call add_json_bool, 	Uses_qcom_um_4_4_family, 			$(filter true,$(TARGET_USES_QCOM_UM_4_4_FAMILY)))
$(call add_json_bool, 	Uses_qcom_um_4_9_family, 			$(filter true,$(TARGET_USES_QCOM_UM_4_9_FAMILY)))
$(call add_json_bool, 	Uses_qcom_um_4_14_family, 			$(filter true,$(TARGET_USES_QCOM_UM_4_14_FAMILY)))
$(call add_json_bool, 	Target_camera_needs_client_info, 		$(filter true,$(TARGET_CAMERA_NEEDS_CLIENT_INFO)))
$(call add_json_str_omitempty, Target_init_vendor_lib, 			$(TARGET_INIT_VENDOR_LIB))
$(call add_json_bool, Uses_qti_camera_device, 				$(filter true,$(TARGET_USES_QTI_CAMERA_DEVICE)))
$(call add_json_bool, Uses_motorized_camera, 				$(filter true,$(TARGET_USES_MOTORIZED_CAMERA)))

# This causes the build system to strip out the last comma in our nested struct, to keep the JSON valid.
_json_contents := $(_json_contents)__SV_END

_json_contents := $(_json_contents)    },$(newline)