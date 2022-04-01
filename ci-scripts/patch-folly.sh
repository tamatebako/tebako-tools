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

if [[ "$OSTYPE" == "linux-musl"* ]]; then
# https://github.com/facebook/folly/issues/1478
  restore_and_save "$1/folly/experimental/symbolizer/Elf.cpp"
  re="#elif defined(__FreeBSD__)"
  sbst="#else    \/* Tebako patched *\/"
  sed -i "s/$re/$sbst/g" "$1/folly/experimental/symbolizer/Elf.cpp"

  restore_and_save "$1/CMake/FollyConfigChecks.cmake"
  re="FOLLY_HAVE_IFUNC"
  sbst="FOLLY_HAVE_IFUNC_NOT_PATCHED"
  sed -i "s/$re/$sbst/g" "$1/CMake/FollyConfigChecks.cmake"

  re="set(CMAKE_REQUIRED_FLAGS \"\${FOLLY_ORIGINAL_CMAKE_REQUIRED_FLAGS}\")"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
set(CMAKE_REQUIRED_FLAGS \"\${FOLLY_ORIGINAL_CMAKE_REQUIRED_FLAGS}\")

# -- Start of tebako patch --
check_cxx_source_runs(\"
  #pragma GCC diagnostic error \\\"-Wattributes\\\"
  extern \\\"C\\\" int resolved_ifunc(void) { return 0; }
  extern \\\"C\\\" int (*test_ifunc(void))() { return resolved_ifunc; }
  int func() __attribute__((ifunc(\\\"test_ifunc\\\")));
  int main() { return func(); }\"
  FOLLY_HAVE_IFUNC
)
# -- End of tebako patch --
EOM

  sed -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/CMake/FollyConfigChecks.cmake"

fi
