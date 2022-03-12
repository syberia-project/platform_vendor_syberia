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
    mount.ntfs

ifeq ($(BOARD_INCLUDE_CMDLINE_TOOLS),true)
#PRODUCT_PACKAGES += \
    bash \
    htop \
    nano \
    powertop \
    rsync \
    zip

# Openssh
#PRODUCT_PACKAGES += \
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
PRODUCT_PACKAGES += \
    NoCutoutOverlay


#Textclassifier bundle
#PRODUCT_PACKAGES += \
    textclassifier.bundle1

PRODUCT_PACKAGES += \
    GameSpace

#OmniJaws
PRODUCT_PACKAGES += \
    OmniJaws \
    WeatherIcons

# Themes
PRODUCT_PACKAGES += \
    AndroidBlackThemeOverlay

# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig

# Matlog
PRODUCT_PACKAGES += \
    MatLog

# Navbar
PRODUCT_PACKAGES += \
     NavigationBarModeGesturalOverlayFS

# StatusBar icons
PRODUCT_PACKAGES += \
    DoraSignalOverlay \
    StrokeSignalOverlay \
    SneakySignalOverlay \
    XperiaSignalOverlay \
    ZigZagSignalOverlay \
    WavySignalOverlay \
    RoundSignalOverlay \
    InsideSignalOverlay \
    BarsSignalOverlay \
    DoraWiFiOverlay \
    StrokeWiFiOverlay \
    SneakyWiFiOverlay \
    XperiaWiFiOverlay \
    ZigZagWiFiOverlay \
    WavyWiFiOverlay \
    WeedWiFiOverlay \
    RoundWiFiOverlay \
    InsideWiFiOverlay \
    BarsWiFiOverlay \
    AquariumSignalOverlay \
    ButterflySignalOverlay \
    DaunSignalOverlay \
    DecSignalOverlay \
    DeepSignalOverlay \
    EqualSignalOverlay \
    FanSignalOverlay \
    HuaweiSignalOverlay \
    RelSignalOverlay \
    ScrollSignalOverlay \
    SeaSignalOverlay \
    StackSignalOverlay \
    WannuiSignalOverlay \
    WindowsSignalOverlay \
    WingSignalOverlay \
    CircleSignalOverlay \
    IosSignalOverlay \
    MiniSignalOverlay \
    OdinSignalOverlay \
    PillsSignalOverlay \
    RomanSignalOverlay

PRODUCT_PACKAGES += \
    QuickAccessWallet

PRODUCT_PACKAGES += \
    CustomDoze

ifeq ($(EXTRA_UDFPS_ANIMATIONS),true)
PRODUCT_PACKAGES += \
    UdfpsResources
endif

# Repainter integration
PRODUCT_PACKAGES += \
    RepainterServicePriv \
