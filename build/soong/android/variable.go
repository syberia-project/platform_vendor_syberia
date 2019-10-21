package android
type Product_variables struct {
	Additional_gralloc_10_usage_bits struct {
	Cppflags []string
	}

	Has_legacy_camera_hal1 struct {
		Cflags []string
	}

	Needs_legacy_camera_hal1_dyn_native_handle struct {
		Cppflags []string
	}

	Uses_media_extensions struct {
		Cflags []string
	}

	Needs_text_relocations struct {
		Cppflags []string
	}

	Mtk_hardware struct {
		Cflags []string
	}

	Cant_reallocate_omx_buffers struct {
		Cflags []string
	}

	Qcom_bsp_legacy struct {
		Cppflags []string
	}

	Qti_flac_decoder struct {
		Cflags []string
	}

	Uses_generic_camera_parameter_library struct {
		Srcs []string
	}

	Target_uses_qsml struct {
		Cflags []string
		Shared_libs []string
		Header_libs []string
		Required []string
	}

	Target_uses_eigen struct {
		Shared_libs []string
		Required []string
	}

	Target_shim_libs struct {
		Cppflags []string
	}
	Uses_qcom_um_family struct {
		Cflags []string
		Srcs []string
	}
	Uses_qcom_um_3_4_family struct {
		Header_libs []string
		Shared_libs []string
	}
	Uses_qcom_um_3_18_family struct {
		Header_libs []string
		Shared_libs []string
	}
	Uses_qcom_um_4_4_family struct {
		Header_libs []string
		Shared_libs []string
	}
	Uses_qcom_um_4_9_family struct {
		Header_libs []string
		Shared_libs []string
	}
	Uses_qcom_um_4_14_family struct {
		Header_libs []string
		Shared_libs []string
	}
	Target_camera_needs_client_info struct {
		Cppflags []string
	}
	Target_init_vendor_lib struct {
		Whole_static_libs []string
	}
	Needs_camera_boottime_timestamp struct {
		Cppflags []string
		Srcs []string
	}
}

type ProductVariables struct {
	Additional_gralloc_10_usage_bits  *string `json:",omitempty"`
	Has_legacy_camera_hal1						*bool `json:",omitempty"`
	Java_Source_Overlays 						*string `json:",omitempty"`
	Needs_legacy_camera_hal1_dyn_native_handle	*bool `json:",omitempty"`
	Uses_media_extensions						*bool `json:",omitempty"`
	Uses_generic_camera_parameter_library		*bool `json:",omitempty"`
	Specific_camera_parameter_library			*string `json:",omitempty"`
	Needs_text_relocations						*bool `json:",omitempty"`
	Mtk_hardware								*bool `json:",omitempty"`
	QTIAudioPath								*string `json:",omitempty"`
	QTIDisplayPath								*string `json:",omitempty"`
	QTIMediaPath								*string `json:",omitempty"`
	Cant_reallocate_omx_buffers					*bool `json:",omitempty"`
	Qcom_bsp_legacy								*bool `json:",omitempty"`
	Qti_flac_decoder							*bool `json:",omitempty"`
	Target_uses_qsml							*bool `json:",omitempty"`
	Target_uses_eigen							*bool `json:",omitempty"`
	Target_use_sdclang							*bool `json:",omitempty"`
	Target_shim_libs							*string `json:",omitempty"`
	Uses_qcom_um_family  							*bool `json:",omitempty"`
	Uses_qcom_um_3_4_family  						*bool `json:",omitempty"`
	Uses_qcom_um_3_18_family  						*bool `json:",omitempty"`
	Uses_qcom_um_4_4_family  						*bool `json:",omitempty"`
	Uses_qcom_um_4_9_family  						*bool `json:",omitempty"`
	Uses_qcom_um_4_14_family  						*bool `json:",omitempty"`
	Target_camera_needs_client_info  					*bool `json:",omitempty"`
	Target_init_vendor_lib							*string `json:",omitempty"`
	Needs_camera_boottime_timestamp  					*bool `json:",omitempty"`
}
