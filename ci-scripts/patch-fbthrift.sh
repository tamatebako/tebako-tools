#! /bin/bash
# Copyright (c) 2022, [Ribose Inc](https://www.ribose.com).
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

# ....................................................
restore_and_save() {
  echo "Patching $1"
  test -e "$1.old" && cp -f "$1.old" "$1"
  cp -f "$1" "$1.old"
}

do_patch() {
  restore_and_save "$1"
  sed -i "s/$2/$3/g" "$1"
}

# ....................................................
# Surprise, surprise ... Upstream project shall found boost libraries for fbthrift
# https://github.com/facebook/fbthrift/commit/c23af9dee42374d43d2f10e0e07edf1c1c97c328


if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* || "$OSTYPE" == "msys" ]]; then
  gSed="sed"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
find_package(OpenSSL REQUIRED)
# -- Start of tebako patch --
find_package(Boost 1.65 REQUIRED COMPONENTS filesystem)
include_directories(\${Boost_INCLUDE_DIRS})
# -- End of tebako patch --
EOM

elif [[ "$OSTYPE" == "darwin"* ]]; then
  gSed="gsed"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
find_package(OpenSSL REQUIRED)
# -- Start of tebako patch --
find_package(Boost 1.65 REQUIRED COMPONENTS filesystem)
include_directories(\${Boost_INCLUDE_DIRS})
# Suppress superfluous randlib warnings about \"*.a\" having no symbols on MacOSX.
set(CMAKE_C_ARCHIVE_CREATE   \"<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>\")
set(CMAKE_CXX_ARCHIVE_CREATE \"<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>\")
set(CMAKE_C_ARCHIVE_FINISH   \"<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>\")
set(CMAKE_CXX_ARCHIVE_FINISH \"<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>\")
# -- End of tebako patch --
EOM

else
  echo "Unknown OSTYPE=$OSTYPE"
  exit 1
fi

restore_and_save "$1/CMakeLists.txt"
re="find_package(OpenSSL REQUIRED)"
"$gSed" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/CMakeLists.txt"

if [[ "$OSTYPE" == "msys" ]]; then
  re="if(WIN32)"
  sbst="if(MSVC) # tebako patched"
  do_patch "$1/thrift/compiler/CMakeLists.txt" "$re" "$sbst"

  re="ftruncate(file\.fd(), finalBufferSize);"
  sbst="folly::portability::unistd::ftruncate(file.fd(), finalBufferSize); \/* tebako patched *\/"
  do_patch "$1/thrift/lib/cpp2/frozen/FrozenUtil.h" "$re" "$sbst"

fi
