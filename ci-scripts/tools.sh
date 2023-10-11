#!/bin/bash
# Copyright (c) 2023, [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of tebako
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

set -o errexit -o pipefail -o noclobber -o nounset

: "${LOCAL_BUILDS:=/tmp/local_builds}"
: "${LOCAL_INSTALLS:=/opt}"
: "${CMAKE_VERSION:=3.26.5}"
: "${LIBARCHIVE_VERSION:=3.6.2}"
: "${ARCH:=linux-x86_64}"

install_cmake() {
  echo "Running install_cmake version ${CMAKE_VERSION} for ${ARCH}"
  local cmake_install="${LOCAL_BUILDS}/cmake"
  mkdir -p "${cmake_install}"
  pushd "${cmake_install}"
  wget  "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-${ARCH}.sh"
  chmod +x "cmake-${CMAKE_VERSION}-${ARCH}.sh"
  "./cmake-${CMAKE_VERSION}-${ARCH}.sh" --skip-license --prefix=/usr
  popd
  rm -rf "${cmake_install}"
}

build_and_install_libarchive() {
  echo "Running build_and_install_libarchive version $LIBARCHIVE_VERSION"
  local libarchive_build="$LOCAL_BUILDS/libarchive"
  mkdir -p "$libarchive_build"
  pushd "$libarchive_build"
  wget "https://github.com/libarchive/libarchive/releases/download/v$LIBARCHIVE_VERSION/libarchive-$LIBARCHIVE_VERSION.tar.xz"
  tar xf "libarchive-$LIBARCHIVE_VERSION.tar.xz"
  cd "libarchive-$LIBARCHIVE_VERSION"
  ./configure --prefix="$LOCAL_INSTALLS" --without-iconv --without-xml2 --without-expat
  make -j8
  make install
  popd
  rm -rf "$libarchive_build"
}

# shellcheck disable=SC2068
$@
