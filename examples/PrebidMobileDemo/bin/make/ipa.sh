#!/usr/bin/env bash

function info {
    echo "$(tput setaf 2)INFO: $1$(tput sgr0)"
}

function error {
    echo "$(tput setaf 1)ERROR: $1$(tput sgr0)"
}

function banner {
    echo ""
    echo "$(tput setaf 5)######## $1 #######$(tput sgr0)"
    echo ""
}

function ditto_or_exit {
  ditto "${1}" "${2}"
  if [ "$?" != 0 ]; then
    error "Could not copy:"
    error "  source: ${1}"
    error "  target: ${2}"
    if [ ! -e "${1}" ]; then
      error "The source file does not exist"
      error "Did a previous xcodebuild step fail?"
    fi
  error "Exiting 1"
  exit 1
  fi
}

banner "Preparing"

if [ "${XCPRETTY}" = "0" ]; then
    USE_XCPRETTY=
else
    USE_XCPRETTY=`which xcpretty | tr -d '\n'`
fi

if [ ! -z ${USE_XCPRETTY} ]; then
    XC_PIPE='xcpretty -c'
else
    XC_PIPE='cat'
fi

XC_TARGET="PrebidMobileDemo"
XC_PROJECT="PrebidMobileDemo.xcodeproj"
XC_SCHEME="${XC_TARGET}"
XC_CONFIG=Debug

XC_BUILD_DIR="build/ipa"
INSTALL_DIR="Products/ipa"

APP="${XC_TARGET}.app"
DSYM="${APP}.dSYM"
IPA="${XC_TARGET}.ipa"

INSTALLED_APP="${INSTALL_DIR}/${APP}"
INSTALLED_DSYM="${INSTALL_DIR}/${DSYM}"
INSTALLED_IPA="${INSTALL_DIR}/${IPA}"

rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

info "Prepared install directory ${INSTALL_DIR}"

BUILD_PRODUCTS_DIR="${XC_BUILD_DIR}/Build/Products/${XC_CONFIG}-iphoneos"
BUILD_PRODUCTS_APP="${BUILD_PRODUCTS_DIR}/${APP}"
BUILD_PRODUCTS_DSYM="${BUILD_PRODUCTS_DIR}/${DSYM}"

rm -rf "${BUILD_PRODUCTS_APP}"
rm -rf "${BUILD_PRODUCTS_DSYM}"

info "Prepared archive directory"

banner "Building ${IPA}"

if [ -z "${CODE_SIGN_IDENTITY}" ]; then
  COMMAND_LINE_BUILD=1 xcrun xcodebuild \
    -SYMROOT="${XC_BUILD_DIR}" \
    -derivedDataPath "${XC_BUILD_DIR}" \
    -project "${XC_PROJECT}" \
    -scheme "${XC_TARGET}" \
    -configuration "${XC_CONFIG}" \
    -sdk iphoneos \
    ARCHS="armv7 armv7s arm64" \
    VALID_ARCHS="armv7 armv7s arm64" \
    ONLY_ACTIVE_ARCH=NO \
    build | $XC_PIPE
else
  COMMAND_LINE_BUILD=1 xcrun xcodebuild \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    -SYMROOT="${XC_BUILD_DIR}" \
    -derivedDataPath "${XC_BUILD_DIR}" \
    -project "${XC_PROJECT}" \
    -scheme "${XC_TARGET}" \
    -configuration "${XC_CONFIG}" \
    -sdk iphoneos \
    ARCHS="armv7 armv7s arm64" \
    VALID_ARCHS="armv7 armv7s arm64" \
    ONLY_ACTIVE_ARCH=NO \
    build | $XC_PIPE
fi

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE != 0 ]; then
    error "Building ipa failed."
    exit $EXIT_CODE
else
    info "Building ipa succeeded."
fi

banner "Installing"

ditto_or_exit "${BUILD_PRODUCTS_APP}" "${INSTALLED_APP}"
info "Installed ${INSTALLED_APP}"

PAYLOAD_DIR="${INSTALL_DIR}/Payload"
mkdir -p "${PAYLOAD_DIR}"

ditto_or_exit "${INSTALLED_APP}" "${PAYLOAD_DIR}/${APP}"

xcrun ditto -ck --rsrc --sequesterRsrc --keepParent \
  "${PAYLOAD_DIR}" \
  "${INSTALLED_IPA}"

info "Installed ${INSTALLED_IPA}"

info "Done!"
