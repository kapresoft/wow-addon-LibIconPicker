#!/usr/bin/env zsh

BUILD_DIR=./build
SCRIPT_DIR=./dev
RELEASE_SCRIPT=${SCRIPT_DIR}/release.sh
PACKAGE_NAME=Pull-Ext-Lib

_Build() {
    if [[ "$1" = "" ]]; then
        echo "Usage: ./release <pkgmeta-file.yml>"
        return 0
    fi
    local pkgmeta="$1"
    local args="-duz -r ${BUILD_DIR} -m ${SCRIPT_DIR}/${pkgmeta}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    eval "${cmd}" && echo "Execution Complete: ${cmd}"
}
_PostBuild() {
  local cmd1="cp -r ./build/${PACKAGE_NAME}/Core/. ./LibIconPicker/Core/."
    echo "Executing: ${cmd1}"
    eval "${cmd1}" && echo "Execution Complete: ${cmd1}"
}

#_Release pkgmeta-kapresoftlibs-interface.yaml
_Build pkgmeta-dev.yaml && _PostBuild
