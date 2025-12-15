#!/usr/bin/env zsh

ADDON_NAME=LibIconPicker

BUILD_DIR=./build
SCRIPT_DIR=./dev
RELEASE_SCRIPT=${SCRIPT_DIR}/release.sh
PACKAGE_NAME=Pull-Ext-Lib
EXT_LIB_DIR=ExtLib

_Build() {
    if [[ "$1" = "" ]]; then
        echo "Usage: ./release <pkgmeta-file.yml>"
        return 0
    fi
  echo ">> RUNNING BUILD"
    local pkgmeta="$1"
    local args="-duz -r ${BUILD_DIR} -m ${SCRIPT_DIR}/${pkgmeta}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    eval "${cmd}" && echo "Execution Complete: ${cmd}"
}
_PostBuild() {
  echo ">> POST BUILD ACTIONS"
  local dest1="./${ADDON_NAME}/Core/${EXT_LIB_DIR}"
  if [[ ! -d "${dest1}" ]]; then
    echo "Creating dir: ${dest1}"
    mkdir ${dest1} || {
      echo "Failed to create dir: ${dest1}"
      return 0
    }
  fi
  local cmd1="cp -r ./build/${PACKAGE_NAME}/${ADDON_NAME}/Core/${EXT_LIB_DIR}/. ${dest1}"
    echo "Executing: ${cmd1}"
    eval "${cmd1}" && echo "Execution Complete: ${cmd1}"
}

_Build pkgmeta-dev.yaml && _PostBuild
