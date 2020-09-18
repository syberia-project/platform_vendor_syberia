include vendor/syberia/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/syberia/config/BoardConfigQcom.mk
endif

include vendor/syberia/config/BoardConfigSoong.mk
