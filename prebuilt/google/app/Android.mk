# Copyright (C) 2017 Android Open Source Project
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

LOCAL_PATH:= $(call my-dir)

#SoundPicker
include $(CLEAR_VARS)
LOCAL_MODULE := SoundPickerPrebuilt
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
LOCAL_DEX_PREOPT := false
include $(BUILD_PREBUILT)

#Wellbeing
include $(CLEAR_VARS)
LOCAL_MODULE := WellbeingPrebuilt
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_PRIVILEGED_MODULE := true
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
LOCAL_DEX_PREOPT := false
include $(BUILD_PREBUILT)

#MatchMaker
include $(CLEAR_VARS)
LOCAL_MODULE        := MatchmakerPrebuilt
LOCAL_SRC_FILES     := $(LOCAL_MODULE).apk
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := APPS
LOCAL_CERTIFICATE   := PRESIGNED
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_DEX_PREOPT    := false
LOCAL_PRODUCT_MODULE := true
LOCAL_PRIVILEGED_MODULE := true
include $(BUILD_PREBUILT)

#Turbo
include $(CLEAR_VARS)
LOCAL_MODULE        := TurboPrebuilt
LOCAL_SRC_FILES     := $(LOCAL_MODULE).apk
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := APPS
LOCAL_CERTIFICATE   := PRESIGNED
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_DEX_PREOPT    := false
LOCAL_PRODUCT_MODULE := true
LOCAL_PRIVILEGED_MODULE := true
include $(BUILD_PREBUILT)

#SettingsIntelligence
include $(CLEAR_VARS)
LOCAL_MODULE        := SettingsIntelligenceGooglePrebuilt
LOCAL_SRC_FILES     := $(LOCAL_MODULE).apk
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := APPS
LOCAL_CERTIFICATE   := PRESIGNED
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_DEX_PREOPT    := false
LOCAL_PRODUCT_MODULE := true
LOCAL_PRIVILEGED_MODULE := true
include $(BUILD_PREBUILT)

#Calc
include $(CLEAR_VARS)
LOCAL_MODULE        := CalculatorGooglePrebuilt
LOCAL_SRC_FILES     := $(LOCAL_MODULE).apk
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := APPS
LOCAL_CERTIFICATE   := PRESIGNED
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_DEX_PREOPT    := false
LOCAL_PRODUCT_MODULE := true
LOCAL_PRIVILEGED_MODULE := true
include $(BUILD_PREBUILT)