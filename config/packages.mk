# Copyright (C) 2018 ArrowOS
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

# Additional tools
#PRODUCT_PACKAGES += \
    e2fsck \
    fsck.exfat \
    fsck.ntfs \
    mke2fs \
    mkfs.exfat \
    mkfs.ntfs \
    mount.exfat \
    mount.ntfs \
    vim

ifeq ($(BOARD_INCLUDE_CMDLINE_TOOLS),true)
PRODUCT_PACKAGES += \
    bash \
    htop \
    nano \
    powertop \
    rsync \
    zip

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh
endif

# ThemePicker
PRODUCT_PACKAGES += \
    ThemePicker

# Cutout control overlay
#PRODUCT_PACKAGES += \
    NoCutoutOverlay


#Textclassifier bundle
#PRODUCT_PACKAGES += \
    textclassifier.bundle1

#OmniJaws
PRODUCT_PACKAGES += \
    OmniJaws \
    WeatherIcons

#Syberia wallpapers
PRODUCT_PACKAGES += \
    SyberiaPapers

#OmniStyle
#PRODUCT_PACKAGES += \
    OmniStyle

# Accents
PRODUCT_PACKAGES += \
    AccentColorYellowOverlay \
    AccentColorVioletOverlay \
    AccentColorTealOverlay \
    AccentColorRedOverlay \
    AccentColorQGreenOverlay \
    AccentColorPinkOverlay \
    AccentColorLightPurpleOverlay \
    AccentColorIndigoOverlay \
    AccentColorFlatPinkOverlay \
    AccentColorCyanOverlay \
    AccentColorBlueGrayOverlay

# Themes
PRODUCT_PACKAGES += \
    SyberiaThemesStub \
    FontGoogleSansOverlay

# Google
PRODUCT_PACKAGES += \
    MarkupGoogle \
    SoundPickerPrebuilt \
    WellbeingPrebuilt \
    MatchmakerPrebuilt

# Recorder app
PRODUCT_PACKAGES += \
    Recorder

# Some permissions
PRODUCT_COPY_FILES += \
    vendor/syberia/config/permissions/privapp-permissions-recorder.xml:system/etc/permissions/privapp-permissions-recorder.xml
