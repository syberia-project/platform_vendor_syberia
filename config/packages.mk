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
PRODUCT_PACKAGES += \
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

# Themes Dark
PRODUCT_PACKAGES += \
    SettingsDarkTheme \
    SystemDarkTheme \
    SystemUIDarkTheme \
    UpdaterDark \
    WellbeingDark

# Themes Black
PRODUCT_PACKAGES += \
    SettingsBlackTheme \
    SystemBlackTheme \
    SystemUIBlackTheme \
    UpdaterBlackAF

# Syberia theme
PRODUCT_PACKAGES += \
    SystemSyberiaTheme \
    SystemUISyberiaTheme \
    SettingsSyberiaTheme 

# Overlays
PRODUCT_PACKAGES += \
    AmberAccent \
    BlueAccent \
    BlueGreyAccent \
    BrownAccent \
    CyanAccent \
    DeepOrangeAccent \
    DeepPurpleAccent \
    DuiDark \
    GreenAccent \
    GreyAccent \
    IndigoAccent \
    LightBlueAccent \
    LightGreenAccent \
    LimeAccent \
    OrangeAccent \
    PinkAccent \
    PurpleAccent \
    RedAccent \
    RosyAccent \
    SettingsDark \
    SystemDark \
    TealAccent \
    YellowAccent \
    
# QS tile styles
PRODUCT_PACKAGES += \
    QStilesDefault \
    QStilesCircleTrim \
    QStilesSquircleTrim \
    QStilesTwoToneCircle \
    QStilesSquircle \
    QStilesTearDrop \
    QStilesSquare \
    QStilesRoundedSquare

# Switch themes
PRODUCT_PACKAGES += \
    MD2Switch \
    OnePlusSwitch \
    StockSwitch

#Textclassifier bundle
PRODUCT_PACKAGES += \
    textclassifier.bundle1

#OmniJaws
PRODUCT_PACKAGES += \
    OmniJaws \
    WeatherIcons

#Font package
PRODUCT_PACKAGES += \
    Custom-Fonts

#OmniStyle
PRODUCT_PACKAGES += \
    OmniStyle

#Lawnchair
PRODUCT_PACKAGES += \
    Lawnchair \
    LawnConf
