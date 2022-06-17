# Copyright (c) 2022, [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of tamatebako
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
#

if(MINGW)
# These days Windows has its own bash.exe that points to WSL installation even if nothing is installed
# So we (1) go look for 'sh' (presumably we will find MSys version)
#       (2) assume that MSys bash is add_subdirectory
#       (3) convert path to Windows
  execute_process(
    COMMAND "which" "sh"
    RESULT_VARIABLE SH_RES
    OUTPUT_VARIABLE SH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(NOT (SH_RES EQUAL 0))
    message(FATAL_ERROR "Could not find MSystem /usr/bin")
  endif()

  get_filename_component(BASH_DIR "${SH}" DIRECTORY)
  set(BASH "${BASH_DIR}/bash.exe")

  execute_process(
    COMMAND "cygpath" "-w" "${BASH}"
    RESULT_VARIABLE BASH_RES
    OUTPUT_VARIABLE GNU_BASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(NOT (BASH_RES EQUAL 0 AND EXISTS ${GNU_BASH}))
    message(FATAL_ERROR "Could not find gnu bash")
  endif()

  message(STATUS "Using gnu bash at ${GNU_BASH}")
endif(MINGW)
