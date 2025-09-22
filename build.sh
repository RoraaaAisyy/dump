#!/usr/bin/bash
# script compile kernel by me

export KBUILD_BUILD_USER="aisy"
export KBUILD_BUILD_HOST="myrora"
export TZ="Asia/Jakarta"
export CODENAME="earth"
export TIMESTAMP=$(date +"%Y%m%d")-$(date +"%H%M%S")
export VARIANT="ksu+susfs"
export ZIPNAME="z4h-kernel-${CODENAME}-${VARIANT}-${TIMESTAMP}"

# clang path
export PATH="${PWD}/clang/bin:${PATH}"

# build starts
make O=out ARCH=arm64 earth_defconfig
make -j$(nproc --all) O=out LLVM=1 \
  ARCH=arm64 \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  AS=llvm-as \
  NM=llvm-nm \
  STRIP=llvm-strip \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  READELF=llvm-readelf \
  HOSTCC=clang \
  HOSTCXX=clang++ \
  HOSTAR=llvm-ar \
  HOSTLD=ld.lld \
  CROSS_COMPILE=aarch64-linux-gnu- \
  CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
  CONFIG_DEBUG_SECTION_MISMATCH=y | tee -a out/build.log
  
# Move kernel image to anykernel3  zip
if [ ! -f "./out/arch/arm64/boot/Image.gz-dtb" ]; then
    cp ./out/arch/arm64/boot/Image.gz ./anykernel3 
else
    cp ./out/arch/arm64/boot/Image.gz-dtb ./anykernel3 
fi
    # Zip the kernel
    cd ./anykernel3 3
    zip -r9 "${ZIPNAME}".zip * -x .git README.md *placeholder
    cd ..
