# oItsMineZKernel for Nokia 2.1 (Android 10)

<img src="https://fdn2.gsmarena.com/vv/pics/nokia/nokia-21-1.jpg" style="width: 200px;" alt="logo">

Stock Kernel with Linux Stable Upstream ***(3.18.124 --> 3.18.140)*** Based on [Kernel Source](https://github.com/Dynamo8917/android_kernel_nokia_msm8917) by [`Project Dynamo`](https://github.com/Dynamo8917)

## Features

- Based on CAF Kernel Tag ***LA.UM.8.6.r1-03400-89xx.0***
- Kernel Based on ***00WW_4_11I (August 1, 2021)***
- Merge with CAF Kernel Tag ***LA.UM.8.6.r1-05300-89xx.0*** + ***Android Common Kernel*** + ***Linux Stable***
- A little overclock for GPU
- Overclock for Little, Mid and Big CPU
- CPU Input Boost
- HZ Tick Set at 25Hz
- Cortex A53 Optimizations
- WireGuard
- Klapse
- Boeffla Wakelock Blocker
- MSM Hotplug
- ThunderTweaks Support (You can get ThunderTweaks [here](https://github.com/oItsMineZKernel/build/raw/refs/heads/main/ThunderTweaks_v1.1.1.5.apk) to customize kernel features)

## How to Install

- Flash Zip file via `TWRP` recovery based (You can get TWRP [here](https://github.com/Dynamo8917/android_recovery_fih_E2M))
- Install `Kernel Addons` on `/sdcard/oItsMineZKernel-Addons-Dynamo-[version].zip` via Magisk

## Install with Magisk

1. First, download lastest version of Magisk (Highly recommend [`1q23lyc45's Kitsune Mask`](https://github.com/1q23lyc45/KitsuneMagisk))

2. After download kernel zip file. Extract boot.img from zip.

3. Open Magisk and select `Install` on **Magisk** section.

4. ***Don't select `Recovery Mode`*** Because, it make your can't boot to recovery mode and you need to reflash recovery via Fastboot again. Simply, select `NEXT`.

5. Choose `Select and Patch a File`, then select `boot.img` that already extracted.

6. Wait until finish and you can see `magisk_patched-xxxxx_xxxxx.img` that on `Download` folder.

7. Reboot to recovery mode and flash zip file first (If you don't flash zip before), and then flash `magisk_patched-xxxxx_xxxxx.img` on `Download` folder.

8. Reboot system and done!

## Supported Devices

|       Name        |  Codename/Model  |
:------------------:|:----------------:|
|     Nokia 2.1     |       E2M        |
|     Nokia 2V      |       EVW        |

## Revert to Stock Kernel
- You can flash zip file [here](https://github.com/oItsMineZKernel/build/raw/refs/heads/main/oItsMineZKernel-Uninstaller-Nokia_2.1-Dynamo.zip) to restore stock kernel.

## How to Build

1. Copy command below and paste on your terminal to install all necessary dependencies

```
sudo apt update && sudo apt upgrade -y && sudo apt install --no-install-recommends -y build-essential && wget http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb && sudo apt install ./libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb ./python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./python2.7_2.7.18-13ubuntu1.5_amd64.deb && rm -rf *.deb && sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
```

2. Clone repository

```
git clone https://github.com/oItsMineZKernel/android_kernel_nokia_msm8917
```

3. Build it!

```
./build.sh
```

4. After build you can find the kernel zip file at the location below

```
build/export/oItsMineZKernel-Unofficial-[yyyyMMdd]-Nokia2.1-Dynamo.zip
```

5. Flash using TWRP based recovery

6. Test it and enjoy!

## Credits

- [`Project Dynamo`](https://github.com/Dynamo8917) for [Kernel Source](https://github.com/Dynamo8917/android_kernel_nokia_msm8917)
- [`Batu33TR`](https://github.com/Batu33TR) for [ProjectMedusa Kernel](https://github.com/ProjectMedusaAndroid/android_kernel_samsung_msm8917_Q)
- [`Chococatpp`](https://github.com/Chococatpp) for [ProjectSoraki Kernel](https://github.com/Chococatpp/android_kernel_samsung_msm8917_Q)
- [`msm8917-dev`](https://github.com/msm8917-dev) for [LineageOS Kernel](https://github.com/msm8917-dev/android_kernel_samsung_msm8917)