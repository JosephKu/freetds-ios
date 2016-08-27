#!/bin/sh

VERSION="1.00.61"
SDK_VERSION="9.3"
TARGET_SDK_VERSION="8.0"
LIB="freetds"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 x86_64 armv7 armv7s arm64"
CURRENT_PATH=`pwd`
BUILD="x86_64-apple-darwin"
HOST="arm-apple-darwin"
TDS_VER=7.1

echo "Cleaning up..."
rm -rf "${CURRENT_PATH}/build/"

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do

    if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64"  ]]; then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi

    echo "Building ${LIB}-${VERSION} for ${PLATFORM} ${SDK_VERSION} ${ARCH}"

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
    CFLAGS="-arch ${ARCH} -miphoneos-version-min=${TARGET_SDK_VERSION} -isysroot ${SDK}"
    PREFIX="${CURRENT_PATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64"  ]]; then
        ./configure --prefix=$PREFIX --build=${BUILD} --with-tdsver=${TDS_VER} CFLAGS="${CFLAGS}"
    else
        ./configure --prefix=$PREFIX --host=${HOST} --build=${BUILD} --with-tdsver=${TDS_VER} CFLAGS="${CFLAGS}"
    fi

    make && make install
    make clean

done

echo "Copying headers"
cp -r ${CURRENT_PATH}/build/${LIB}/i386/ ${CURRENT_PATH}/build/${LIB}/Fat
rm -rf ${CURRENT_PATH}/build/${LIB}/Fat/lib/*

echo "Building library... freetds.a"
lipo \
        ${CURRENT_PATH}/build/${LIB}/i386/lib/libsybdb.a \
        ${CURRENT_PATH}/build/${LIB}/x86_64/lib/libsybdb.a \
        ${CURRENT_PATH}/build/${LIB}/armv7/lib/libsybdb.a \
        ${CURRENT_PATH}/build/${LIB}/armv7s/lib/libsybdb.a \
        ${CURRENT_PATH}/build/${LIB}/arm64/lib/libsybdb.a \
        -create -output ${CURRENT_PATH}/build/${LIB}/Fat/lib/libsybdb.a

xcrun -sdk iphoneos lipo -info ${CURRENT_PATH}/build/${LIB}/Fat/lib/libsybdb.a

echo "Done."
