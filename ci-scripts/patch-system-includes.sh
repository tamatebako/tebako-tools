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

# Alpine headers define malloc and other memory functions without nothrow attribute
# while jemalloc and folly have nothrow
# clang (as opposed to gcc) considers it syntax error and there is no easier workaround

set -o errexit -o pipefail -o noclobber -o nounset

# ....................................................
restore_and_save() {
  echo "Patching $1"
  test -e "$1.old" && cp -f "$1.old" "$1"
  cp -f "$1" "$1.old"
}

patch() {
  echo "Processing $2"
  re="$2"
  sbst="__attribute__((nothrow)) \/*Tebako patched *\/ $2"
  sed -i "s/$re/$sbst/g" "$1"
}

f_stdlib=( "\*malloc" "\*calloc" "\*realloc" "free" "\*aligned_alloc" "posix_memalign" "\*valloc" "\*memalign" )
restore_and_save "/usr/include/stdlib.h"
for f in "${f_stdlib[@]}"
do
	patch "/usr/include/stdlib.h" "$f"
done

f_sched=( "\*calloc" "free" )
restore_and_save "/usr/include/sched.h"
for f in "${f_sched[@]}"
do
	patch "/usr/include/sched.h" "$f"
done
