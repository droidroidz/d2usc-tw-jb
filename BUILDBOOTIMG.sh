#!/bin/bash

##	/home/kgfries/Android/android-toolchain-eabi/bin/arm-linux-androideabi-
    THREADS=$(expr 4 + $(grep processor /proc/cpuinfo | wc -l))
    DEFCONFIG=lk_defconfig
    ARCH="ARCH=arm"
    DIR=/home/droidroidz/ANDROID/DROIDZ.KERNEL.SRCS
    RAMDISK=$DIR/lk_tw_jb_vzw_usc1/lk.ramdisk_usc_leaned
    TOOLS=$DIR/TOOLS
    KERNEL=$DIR/lk_tw_jb_vzw_usc1
    PACK=$KERNEL/zip_file
    OUT=$KERNEL/arch/arm/boot
    LOG=$TOOLS/log.txt
    CWM=$PACK/droidroidz

    # Edit this to change the kernel name
    KBUILD_BUILD_VERSION="-"
    export KBUILD_BUILD_VERSION

    MAKE="make -j${THREADS}"
    export USE_CCACHE=1
    export $ARCH

    # This cleans out crud and makes new config
    $MAKE clean
    $MAKE mrproper
    #rm -rf $RAMDISK/system/lib    ADD THESE BACK LATER
    #rm -rf $PACK/*
    $MAKE $DEFCONFIG

    echo "All clean!" > $LOG
    date >> $LOG
    echo "" >> $LOG

    # Finally making the kernel
    make ARCH=arm -j3 CROSS_COMPILE=/home/droidroidz/ANDROID/_TOOLCHAINS/android-toolchain-eabi-linaro/bin/arm-eabi-

    echo "Compiled" >> $LOG
    date >> $LOG
    echo "" >> $LOG

    # This command will detect if the folder is there and if not will recreate it
    #[ -d "$RAMDISK/system/lib/modules" ] || mkdir -p "$RAMDISK/system/lib/modules"

    # Move Modules to CWM location
    find -name '*.ko' -exec cp -av {} $CWM/system/lib/modules/ \;
    find . -type f -name '*.ko' | xargs -n 1 /home/droidroidz/ANDROID/_TOOLCHAINS/android-toolchain-eabi-linaro/bin/arm-eabi-strip --strip-unneeded

    cp $OUT/zImage $PACK

    # This part packs the img up :)
    # In order for this part to work you need the mkbootimg tools

    cd $RAMDISK
    chmod 750 init*
    chmod 644 default* uevent* MSM*
    chmod 755 sbin
    chmod 700 sbin/lkflash sbin/lkconfig

    $TOOLS/mkbootfs $RAMDISK | gzip > $PACK/ramdisk.gz
    $TOOLS/mkbootimg --cmdline "console=null androidboot.hardware=qcom user_debug=31" --kernel $PACK/zImage --ramdisk $PACK/ramdisk.gz --base 0x80200000 --ramdiskaddr 0x81500000 -o $PACK/boot.img

    echo "packed" >> $LOG
    date >> $LOG


    
    #CWM flashable
    cp $PACK/boot.img $CWM/boot.img
    cd $CWM
    zip -r -9 imoseyon-droidz-jb-v1.2.1.vbox.zip .
    

