#! /bin/bash
# Copyright (c) 2022-2025 [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of the Tebako project.
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
  "$gSed" -i "s/$2/$3/g" "$1"
}

do_patch_multiline() {
  restore_and_save "$1"
  "$gSed" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1"
}

if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* || "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  gSed="sed"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  gSed="gsed"
else
  echo "Unknown OSTYPE=$OSTYPE"
  exit 1
fi

re="cmake_minimum_required(VERSION 3.1.3 FATAL_ERROR)"
sbst="cmake_minimum_required(VERSION 3.24.0)"
do_patch "$1/CMakeLists.txt"  "$re" "$sbst"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  re="ftruncate(file\.fd(), finalBufferSize),"
  sbst="folly::portability::unistd::ftruncate(file.fd(), finalBufferSize), \/* tebako patched *\/"
  do_patch "$1/thrift/lib/cpp2/frozen/FrozenUtil.h" "$re" "$sbst"

  re="if (detail::platform_is_windows()) {"
  sbst="if (false) { \/* tebako patched *\/"
  do_patch "$1/thrift/compiler/source_location.cc" "$re" "$sbst"

  re="#include <fmt\/fmt-format\.h>"
 # shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <fmt\/format.h>

\/* -- Start of tebako patch -- *\/
#include <fmt\/fmt-ranges.h>
\/* -- End of tebako patch -- *\/
EOM

do_patch_multiline "$1/thrift/compiler/lib/cpp2/util.h" "$re" "$sbst"
do_patch_multiline "$1/thrift/compiler/gen/cpp/namespace_resolver.cc" "$re" "$sbst"
do_patch_multiline "$1/thrift/compiler/ast/t_const_value.h" "$re" "$sbst"

fi
