function __print_extra_functions_help() {
cat <<EOF
Additional functions:
- mka:             Builds using SCHED_BATCH on all processors.
- pushboot:	   Push a file from your OUT dir to your phone
                   and reboots it, using absolute path.
- repopick:        Utility to fetch changes from Gerrit.
- aospremote:      Add git remote for matching AOSP repository.
- cafremote:       Add git remote for matching CodeAurora repository.
- repopick:        Utility to fetch changes from Gerrit.
EOF
}

# Make using all available CPUs
function mka() {
    case `uname -s` in
        Darwin)
            make -j `sysctl hw.ncpu|cut -d" " -f2` "$@"
            ;;
        *)
            make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@"
            ;;
    esac
}

function breakfast()
{
    target=$1
    SYBERIA_DEVICES_ONLY="true"
    unset LUNCH_MENU_CHOICES
    add_lunch_combo full-eng
       for f in $(test -d $ANDROID_BUILD_TOP/vendor/syberia && \
            find -L $ANDROID_BUILD_TOP/vendor/syberia  -maxdepth 4 -name 'vendorsetup.sh' 2>/dev/null | sort); do
            echo "including $f"
            . $f
        done
    unset f

    if [ $# -eq 0 ]; then
        # No arguments, so let's have the full menu
        echo "Nothing to eat for breakfast?"
        lunch
    else
        if [[ "$target" =~ -(user|userdebug|eng)$ ]]; then
            # A buildtype was specified, assume a full device name
            lunch $target
        else
            # This is probably just the SYBERIA model name
            lunch syberia_$target-userdebug
        fi
    fi
    return $?
}

alias bib=breakfast

function pushboot() {
    if [ ! -f $OUT/$* ]; then
        echo "File not found: $OUT/$*"
        return 1
    fi

    adb root
    sleep 1
    adb wait-for-device
    adb remount

    adb push $OUT/$* /$*
    adb reboot
}

function aospremote() {
    git remote rm aosp 2> /dev/null
    if [ ! -d .git ]
    then
        echo .git directory not found. Please run this from the root directory of the Android repository you wish to set up.
    fi
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##")
    if (echo $PROJECT | grep -qv "^device")
    then
        PFX="platform/"
    fi
    git remote add aosp https://android.googlesource.com/$PFX$PROJECT
    echo "Remote 'aosp' created"
}
export -f aospremote

function cafremote()
{
    git remote rm caf 2> /dev/null
    if [ ! -d .git ]
    then
        echo .git directory not found. Please run this from the root directory of the Android repository you wish to set up.
    fi
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##")
    if (echo $PROJECT | grep -qv "^device")
    then
        PFX="platform/"
    fi
    git remote add caf https://source.codeaurora.org/quic/la/$PFX$PROJECT
    echo "Remote 'caf' created"
}
export -f cafremote

function repopick() {
    T=$(gettop)
    $T/vendor/syberia/build/tools/repopick.py $@
}
 function fixup_common_out_dir() {
    common_out_dir=$(get_build_var OUT_DIR)/target/common
    target_device=$(get_build_var TARGET_DEVICE)
    if [ ! -z $CM_FIXUP_COMMON_OUT ]; then
        if [ -d ${common_out_dir} ] && [ ! -L ${common_out_dir} ]; then
            mv ${common_out_dir} ${common_out_dir}-${target_device}
            ln -s ${common_out_dir}-${target_device} ${common_out_dir}
        else
            [ -L ${common_out_dir} ] && rm ${common_out_dir}
            mkdir -p ${common_out_dir}-${target_device}
            ln -s ${common_out_dir}-${target_device} ${common_out_dir}
        fi
    else
        [ -L ${common_out_dir} ] && rm ${common_out_dir}
        mkdir -p ${common_out_dir}
    fi
}

# Enable ThinLTO Source wide.
echo "Building with ThinLTO."
export GLOBAL_THINLTO=true
export USE_THINLTO_CACHE=true

# For now, just skip the ABI checks to fix build errors.
export SKIP_ABI_CHECKS=true

# Override host metadata to make builds more reproducible and avoid leaking info
export BUILD_USERNAME=nobody
export BUILD_HOSTNAME=android-build
