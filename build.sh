#!/bin/bash

separator () {
  echo "---------------------------------------------------------"
}

quotes () {
  echo "-- $1..."
}

noquotes () {
  echo "-- $1"
}

clean () {
    separator
    quotes "Cleaning Up Build Files"

    cd $DIR && rm -rf o* .w* build/AIK/*.c* build/AIK/s* build/*.p* build/*er* && git restore arch/arm/configs/$KERNEL_DEFCONFIG

    if [[ "$CLEAN" == "y" ]]; then
        separator
        quotes "Revert all Change to Latest Commit (All Uncommit Change will Lost!)"
        separator
        rm -rf K* toolc* build/A* build/m* build/s* build/u* && git clean -df && git reset --hard HEAD
    fi
}

abort () {
    cd -

    if [[ "$CLEAN" == "y" ]]; then
        clean
    fi

    separator
    quotes "Failed to Compile Kernel! Exiting"
    separator

    exit -1
}

check () {
    if [ $? -eq 0 ]; then
        echo "-- Setup $1 Done!"
    else
        quotes "Failed! Cancel the Script"
        abort
    fi
}

submodule () {
    separator
    quotes "Fetch all Submodules Update"

    git submodule update -f -q --init --recursive > /dev/null
    check "Submodules"
}

nosudo () {
    clean
    noquotes "You Need to Run Script with \"sudo\" (sudo ./build.sh) to Install all Dependencies"
    separator

    exit -1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ver|-v)
            KERNEL_VERSION="$2"
            shift 2
            ;;
        --rel|-r)
            RELEASE="$2" # Use when Run on GitHub Actions (y: Release - n: CI)
            shift 2
            ;;
        --clean|-c)
            CLEAN="$2"
            shift 2
            ;;
        *)\
            exit 1
            ;;
    esac
done

detect_env () {
    # Set Build Variable
    separator

    DATE=`date +"%Y%m%d"`
    REPO_URL="https://raw.githubusercontent.com/oItsMineZKernel/build/refs/heads/dynamo/"
    export KBUILD_BUILD_USER=oItsMineZ
    export KBUILD_BUILD_HOST=Kernel

    KERNEL_DEFCONFIG=oitsminez-E2M-perf_defconfig
    DEVICE="Nokia 2.1"
    MODEL=Dynamo
    SOC="Snapdragon 425 (MSM8917)"

    if [ ! -z $RELEASE ]; then
        quotes "Running on GitHub Actions"
        echo BUILD_DEVICE=${DEVICE// /_} >> $GITHUB_ENV
        echo BUILD_MODEL=$MODEL >> $GITHUB_ENV
    else
        quotes "Running on Local Machine"
        LOCAL=y
    fi

    if [ -z $KERNEL_VERSION ]; then
        KERNEL_VERSION=Unofficial
    fi

    if [ -z $CLEAN ]; then
        CLEAN=n
    fi

    separator

    if test -f "/usr/bin/python2.7" && test -f "/usr/bin/python2"; then
        quotes "Python 2.7 Directory Found!"
    else
        quotes "Python 2.7 Not Found! Starting the Installer"
        if [[ $EUID -ne 0 ]]; then
            nosudo
        else
            quotes "Installing Python 2.7"
            separator

            wget http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb
            sudo apt install ./libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb ./python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./python2.7_2.7.18-13ubuntu1.5_amd64.deb
            rm -rf *.deb

            if test -f "/usr/bin/python2"; then
                rm -rf /usr/bin/python2
            fi

            sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
            check "Python 2.7"
        fi
    fi

    if test -d "build/AIK"; then
        quotes "Android Image Kitchen Directory Found!"
    else
        quotes "Add Android Image Kitchen as Submodule"
        git submodule add -f -q https://github.com/oItsMineZKernel/Android-Image-Kitchen build/AIK > /dev/null && chmod +x build/AIK/mk*
        check "Android Image Kitchen Directory"
    fi

    if ! test -f "build/AIK/ramdisk/init"; then
        quotes "Getting Ramdisk Binary"

        if ! test -d "build/AIK/ramdisk"; then
            mkdir -p build/AIK/ramdisk
        fi

        curl -LSs "${REPO_URL}init" -o build/AIK/ramdisk/init && chmod +x build/AIK/ramdisk/i*
        check "Ramdisk Binary"
    fi

    if ! test -f "build/module-binary"; then
        quotes "Getting Module Binary"
        curl -LSs "https://raw.githubusercontent.com/Zackptg5/MMT-Extended/refs/heads/master/META-INF/com/google/android/update-binary" -o build/module-binary
        check "Module Binary"
    fi

    quotes "Getting Module Props"
    curl -LOSs "${REPO_URL}module.prop" && curl -LOSs "${REPO_URL}system.prop" && mv *.p* build
    check "Module Props"

    if ! test -f "build/update-binary"; then
        quotes "Getting Kernel Binary"
        curl -LOSs "${REPO_URL}update-binary"
        check "Kernel Binary"
    fi

    quotes "Getting Kernel Script"
    curl -LOSs "${REPO_URL}updater-script" && mv up* build
    check "Kernel Script"

    check "Build Environment"
}

toolchain () {
    separator

    if test -d "toolchain"; then
        quotes "arm-linux-androideabi-4.9 Directory Found!"
    else
        quotes "Add arm-linux-androideabi-4.9 as Submodule"
        git submodule add -f -q https://github.com/arter97/arm-linux-androideabi-4.9 toolchain/arm-linux-androideabi-4.9 > /dev/null
        check "arm-linux-androideabi-4.9"
    fi

    GCC=$DIR/toolchain/arm-linux-androideabi-4.9/bin/
    ARGS="
        ARCH=arm O=out \
        KCFLAGS=-mno-android \
        CROSS_COMPILE=${GCC}arm-linux-androideabi- \
    "
}

kernel () {
    # Build Kernel Image
    separator
    noquotes "Fetch Kernel Info"
    separator
    noquotes "Device: $DEVICE ("$MODEL")"
    noquotes "SOC: $SOC"
    noquotes "Defconfig: $KERNEL_DEFCONFIG"
    noquotes "Kernel Version: $KERNEL_VERSION"
    noquotes "Build Date: `date +"%Y-%m-%d"`"

    sed -i "s/CONFIG_LOCALVERSION=\"-perf\"/CONFIG_LOCALVERSION=\"-oItsMineZKernel-$KERNEL_VERSION-$DEVICE-$MODEL\"/" arch/arm/configs/$KERNEL_DEFCONFIG

    separator
    noquotes "Building Kernel Using $KERNEL_DEFCONFIG"
    quotes "Generating Configuration Files"
    separator

    make -j$(nproc --all) $ARGS $KERNEL_DEFCONFIG || abort

    separator
    quotes "Building Kernel"
    separator

    make -j$(nproc --all) $ARGS || abort

    separator
    quotes "Finished Kernel Build!"

    rm -rf $DIR/build/out/$MODEL
    mkdir -p $DIR/build/out/$MODEL
}

ramdisk () {
    # Build Ramdisk
    separator
    quotes "Building Ramdisk"
    separator

    rm -f $DIR/build/AIK/s*
    mkdir -p $DIR/build/AIK/split_img
    cp $DIR/out/arch/arm/boot/zImage-dtb $DIR/build/AIK/split_img/boot.img-kernel
    echo -e "0x80000000" > build/AIK/split_img/boot.img-base
    echo -e "" > build/AIK/split_img/boot.img-board
    echo -e "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom androidboot.memcg=true user_debug=30 msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78B0000 loop.max_part=7 loglevel=0 loglevel=0 buildvariant=user veritykeyid=id:8f56f02c61394639f13af4e8cfe02d087e41b936" > build/AIK/split_img/boot.img-cmdline
    echo -e "sha1" > build/AIK/split_img/boot.img-hashtype
    echo -e "0" > build/AIK/split_img/boot.img-header_version
    echo -e "AOSP" > build/AIK/split_img/boot.img-imgtype
    echo -e "0x00008000" > build/AIK/split_img/boot.img-kernel_offset
    echo -e "16777216" > build/AIK/split_img/boot.img-origsize
    echo -e "2021-08" > build/AIK/split_img/boot.img-os_patch_level
    echo -e "10.0.0" > build/AIK/split_img/boot.img-os_version
    echo -e "2048" > build/AIK/split_img/boot.img-pagesize
    echo -e "0x01000000" > build/AIK/split_img/boot.img-ramdisk_offset
    echo -e "gzip" > build/AIK/split_img/boot.img-ramdiskcomp
    echo -e "0x00f00000" > build/AIK/split_img/boot.img-second_offset
    echo -e "0x00000100" > build/AIK/split_img/boot.img-tags_offset

    # Create Boot Image
    quotes "Calling Android Image Kitchen"

    cd $DIR/build/AIK && ./mkimg
}

build_zip () {
    # Build Zip
    separator
    quotes "Building Zip"
    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        separator
    fi

    rm -rf $DIR/build/out/$MODEL/zip
    mkdir -p $DIR/build/export
    mkdir -p $DIR/build/out/$MODEL/zip/module/common/
    mkdir -p $DIR/build/out/$MODEL/zip/module/META-INF/com/google/android
    mkdir -p $DIR/build/out/$MODEL/zip/META-INF/com/google/android
    mv $DIR/build/AIK/image-new.img $DIR/build/out/$MODEL/boot-patched.img
    mv $DIR/out/drivers/staging/prima/wlan.ko $DIR/build/out/$MODEL/zip/pronto_wlan.ko

    cp $DIR/build/out/$MODEL/boot-patched.img $DIR/build/out/$MODEL/zip/boot.img
    cp $DIR/build/update-binary $DIR/build/out/$MODEL/zip/META-INF/com/google/android/
    cp $DIR/build/updater-script $DIR/build/out/$MODEL/zip/META-INF/com/google/android/

    cp $DIR/build/module.prop $DIR/build/out/$MODEL/zip/module/
    cp $DIR/build/system.prop $DIR/build/out/$MODEL/zip/module/common/
    cp $DIR/build/module-binary $DIR/build/out/$MODEL/zip/module/META-INF/com/google/android/update-binary
    echo -e "#MAGISK" > $DIR/build/out/$MODEL/zip/module/META-INF/com/google/android/updater-script

    cd $DIR/build/out/$MODEL/zip/module
    zip -r ../module.zip .
    rm -rf $DIR/build/out/$MODEL/zip/module

    sed -i "s/ui_print(\" Kernel Version: \");/ui_print(\" Kernel Version: $KERNEL_VERSION\");/" $DIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Device: \");/ui_print(\" Kernel Device: $DEVICE ($MODEL)\");/" $DIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Toolchain: \");/ui_print(\" Kernel Toolchain: arm-linux-androideabi-4.9\");/" $DIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/CONFIG_LOCALVERSION=\"-oItsMineZKernel-$KERNEL_VERSION-$DEVICE-$MODEL\"/CONFIG_LOCALVERSION=\"-oItsMineZKernel-$KERNEL_VERSION-$DATE-$DEVICE-$MODEL\"/" $DIR/arch/arm/configs/$KERNEL_DEFCONFIG

    NAME=$(grep -o 'CONFIG_LOCALVERSION="[^"]*"' $DIR/arch/arm/configs/$KERNEL_DEFCONFIG | cut -d '"' -f 2)
    NAME=${NAME:1}
    NAME=${NAME// /_}.zip

    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        cd $DIR/build/out/$MODEL/zip
        zip -r ../"$NAME" .
        rm -rf $DIR/build/out/$MODEL/zip
        mv $DIR/build/out/$MODEL/"$NAME" $DIR/build/export/"$NAME"
        cd $DIR/build/export
    fi
}

# Main Function
rm -rf ./build.log (
    START=`date +%s`
    DIR=$(pwd)

    separator
    quotes "Preparing the Build Environment"

    detect_env
    toolchain

    if [[ "$LOCAL" == "y" ]]; then
        submodule
    fi

    kernel
    ramdisk
    build_zip

    if [[ "$LOCAL" == "y" ]]; then
        clean
        separator
    fi

    END=`date +%s`

    let "ELAPSED=$END-$START"

    quotes "Total Compile Time was $(($ELAPSED / 60)) Minutes and $(($ELAPSED % 60)) Seconds"
    separator
) 2>&1	| tee -a ./build.log
