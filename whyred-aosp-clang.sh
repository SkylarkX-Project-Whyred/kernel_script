#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Copyright (C) 2020 Fiqri Ardyansyah (fiqri19102002)
# Copyright (C) 2020 Agung Pratama (skylarkAurora)
# For Redmi Note 9 Pro (sdm720G)

# Color
green='\033[0;32m'
echo -e "$green"

# Main Environment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel3
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs
CONFIG=joyeuse_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$PWD/toolchain/bin/aarch64-linux-gnu-"

# Export
export ARCH=arm64
export SUBARCH=arm64
export PATH=/usr/lib/ccache:$PATH
export CROSS_COMPILE
export CC=$PWD/proton/bin/proton
export KBUILD_COMPILER_STRING=$($CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CLANG_TREPLE=aarch64-linux-gnu-
export KBUILD_BUILD_USER="AgungPratamma"
export KBUILD_BUILD_HOST="Manjaro-Linux-Dev"

# Banner
echo -e "  ___  ___  _ __ (_) ___"
echo -e "/ __|/ _ \| '_ \| |/ __| "
echo -e "\__ \ (_) | | | | | (__ "
echo -e "|___/\___/|_| |_|_|\___| "
echo -e " "
echo -e " _  __ _____  ____   _   _  _____  _     	"
echo -e "| |/ /| ____||  _ \ | \ | || ____|| |      "
echo -e "| | / |  _|  | |_) ||  \| ||  _|  | |      "
echo -e "| | \ | |___ |  _ < | |\  || |___ | |___   "
echo -e "|_|\_\|_____||_| \_\|_| \_||_____||_____|  "

# Main script
while true; do
echo -e "\n############################################################################"
echo -e " "
echo -e "[1] Build Joyeuse AOSP Kernel"
echo -e "[2] Regenerate defconfig"
echo -e "[3] Source cleanup"
echo -e "[4] Create flashable zip"
echo -e "[5] Quit"
echo -e " "
echo -e "############################################################################"
echo -ne "\n(i) Please enter a choice[1-5]: "
	
	read choice
	
	if [ "$choice" == "1" ]; then
		echo -e "\n(i) Cloning AnyKernel3 if folder not exist..."
		git clone https://github.com/SkylarkX-Project-Whyred/AnyKernel3 -b whyred-aosp --depth=1 AnyKernel3
	
		echo -e "\n(i) Cloning clang if folder not exist..."
		https://github.com/kdrag0n/proton-clang.git -b master --depth=1 proton
		
		echo -e "\n(i) Cloning toolchain if folder not exist..."
		git clone https://github.com/najahiiii/aarch64-linux-gnu.git -b linaro8-20190402 --depth=1 toolchain
		
		echo -e ""
		make  O=out $CONFIG $THREAD &>/dev/null
		make  O=out $THREAD & pid=$!   
	
		BUILD_START=$(date +"%s")
		DATE=`date`

		echo -e "\n#######################################################################"

		echo -e "(i) Build started at $DATE using $CORES thread"
		
		echo -e "(i) This takes a few minutes, please wait a moment !!!"

		spin[0]="-"
		spin[1]="\\"
		spin[2]="|"
		spin[3]="/"
		echo -ne "\n[Please wait...] ${spin[0]}"
		while kill -0 $pid &>/dev/null
		do
			for i in "${spin[@]}"
			do
				echo -ne "\b$i"
				sleep 0.1
			done
		done
	
		if ! [ -a $KERN_IMG ]; then
			echo -e "\n(!) Kernel compilation failed, See buildlog to fix errors"
			echo -e "#######################################################################"
			exit 1
		fi
	
		BUILD_END=$(date +"%s")
		DIFF=$(($BUILD_END - $BUILD_START))

		echo -e "\n(i) Image-dtb compiled successfully."

		echo -e "#######################################################################"

		echo -e "(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "2" ]; then
		echo -e "\n#######################################################################"

		make O=out  $CONFIG savedefconfig &>/dev/null
		cp out/defconfig arch/arm64/configs/$CONFIG &>/dev/null

		echo -e "(i) Defconfig generated."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "3" ]; then
		echo -e "\n#######################################################################"

		make O=out clean &>/dev/null
		make mrproper &>/dev/null
		rm -rf out/*

		echo -e "(i) Kernel source cleaned up."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "4" ]; then
		echo -e "\n#######################################################################"

		cd $ZIP_DIR
		make clean &>/dev/null
		cp $KERN_IMG $ZIP_DIR/Image.gz-dtb
		make normal &>/dev/null
		cd ..

		echo -e "(i) Flashable zip generated under $ZIP_DIR."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "5" ]; then
		exit 
	fi

done
echo -e "$nc"
