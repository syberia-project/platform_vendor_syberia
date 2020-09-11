# Copyright (C) 2017 Unlegacy-Android
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------
# Bacon update package

# Shell color defs:
CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

MD5 := prebuilts/build-tools/path/$(HOST_OS)-x86/md5sum

ifeq ($(TARGET_BACON_NAME),)
    INTERNAL_BACON_NAME := $(TARGET_PRODUCT)-$(PLATFORM_VERSION)-$(shell date -u +%Y%m%d)
else
    INTERNAL_BACON_NAME := $(TARGET_BACON_NAME)
endif

INTERNAL_BACON_TARGET := $(PRODUCT_OUT)/$(INTERNAL_BACON_NAME).zip

.PHONY: bacon syberia
bacon: syberia
syberia: $(INTERNAL_OTA_PACKAGE_TARGET)
	 $(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(INTERNAL_BACON_TARGET)
	 $(hide) $(MD5) $(INTERNAL_BACON_TARGET) | sed "s|$(PRODUCT_OUT)/||" > $(INTERNAL_BACON_TARGET).md5sum
	 @echo "Package Complete: $(INTERNAL_BACON_TARGET)" >&2
	 @echo -e ${CL_RST}"                                                                    "${CL_RST}
	 @echo -e ${CL_RED}"                                                                    "${CL_RED}
	 @echo -e ${CL_RED}"          ██████▓██   ██▓ ▄▄▄▄   ▓█████  ██▀███   ██▓ ▄▄▄           "${CL_RED}
	 @echo -e ${CL_RED}"        ▒██    ▒ ▒██  ██▒▓█████▄ ▓█   ▀ ▓██ ▒ ██▒▓██▒▒████▄         "${CL_RED}
	 @echo -e ${CL_RED}"        ░ ▓██▄    ▒██ ██░▒██▒ ▄██▒███   ▓██ ░▄█ ▒▒██▒▒██  ▀█▄       "${CL_RED}
	 @echo -e ${CL_RED}"          ▒   ██▒ ░ ▐██▓░▒██░█▀  ▒▓█  ▄ ▒██▀▀█▄  ░██░░██▄▄▄▄██      "${CL_RED}
	 @echo -e ${CL_RED}"       ▒██████▒▒ ░ ██▒▓░░▓█  ▀█▓░▒████▒░██▓ ▒██▒░██░ ▓█   ▓██▒      "${CL_RED}
	 @echo -e ${CL_RED}"      ▒ ▒▓▒ ▒ ░  ██▒▒▒ ░▒▓███▀▒░░ ▒░ ░░ ▒▓ ░▒▓░░▓   ▒▒   ▓▒█░       "${CL_RED}
	 @echo -e ${CL_RED}"      ░ ░▒  ░ ░▓██ ░▒░ ▒░▒   ░  ░ ░  ░  ░▒ ░ ▒░ ▒ ░  ▒   ▒▒ ░       "${CL_RED}
	 @echo -e ${CL_RED}"	  ░  ░  ░  ▒ ▒ ░░   ░    ░    ░     ░░   ░  ▒ ░  ░   ▒          "${CL_RED}
	 @echo -e ${CL_RST}"                                                                    "${CL_RST}
	 @echo -e ${CL_RST}"         Build completed! Now flash that shit and enjoy!!           "${CL_RST}
	 @echo -e ${CL_RST}"                                                                    "${CL_RST}
	 @echo -e ${CL_RED}"===================================================================="${CL_RED}
	 @echo -e ${CL_RST}"$(INTERNAL_BACON_TARGET)                                            "${CL_RST}
	 @echo -e ${CL_BLD}${CL_YLW}"MD5: "${CL_YLW}" `cat $(INTERNAL_BACON_TARGET).md5sum | awk '{print $$1}' `"${CL_RST}
	 @echo -e ${CL_BLD}${CL_YLW}"Size:"${CL_YLW}" `du -sh $(INTERNAL_BACON_TARGET) | awk '{print $$1}' `"${CL_RST}
	 @echo -e ${CL_RED}"===================================================================="${CL_RED}
	 @echo -e ${CL_RST}"                                                                    "${CL_RST}