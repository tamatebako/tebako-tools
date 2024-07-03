# Copyright (c) 2021-2024, [Ribose Inc](https://www.ribose.com).
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

if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
  execute_process(
    COMMAND brew --prefix
    RESULT_VARIABLE BREW_PREFIX_RES
    OUTPUT_VARIABLE BREW_PREFIX_TMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT (BREW_PREFIX_RES EQUAL 0 AND EXISTS ${BREW_PREFIX_TMP}))
    message(FATAL "Could not find build brew setup")
  else()
    set(BREW_PREFIX "${BREW_PREFIX_TMP}" CACHE PATH "Brew installation prefix")
  endif()

  message(STATUS "Using brew environment at ${BREW_PREFIX}")
  # https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.me
  set(OPENSSL_ROOT_DIR "${BREW_PREFIX}/opt/openssl@3")
  set(CMAKE_PREFIX_PATH "${BREW_PREFIX}")
  include_directories("${OPENSSL_ROOT_DIR}/include")
  include_directories("${BREW_PREFIX}/include")

  #  https://stackoverflow.com/questions/53877344/cannot-configure-cmake-to-look-for-homebrew-installed-version-of-bison
  execute_process(
    COMMAND brew --prefix bison
    RESULT_VARIABLE BREW_BISON
    OUTPUT_VARIABLE BREW_BISON_PREFIX_TMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if (BREW_BISON EQUAL 0 AND EXISTS "${BREW_BISON_PREFIX_TMP}")
    set(BREW_BISON_PREFIX "${BREW_BISON_PREFIX_TMP}" CACHE PATH "Bison prefix")
    message(STATUS "Found Bison keg installed by Homebrew at ${BREW_BISON_PREFIX}")
    set(BISON_EXECUTABLE "${BREW_BISON_PREFIX}/bin/bison" CACHE FILEPATH "Bison executable")
  endif()

  execute_process(
    COMMAND brew --prefix flex
    RESULT_VARIABLE BREW_FLEX
    OUTPUT_VARIABLE BREW_FLEX_PREFIX_TMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if (BREW_FLEX EQUAL 0 AND EXISTS "${BREW_FLEX_PREFIX_TMP}")
  set(BREW_FLEX_PREFIX "${BREW_FLEX_PREFIX_TMP}" CACHE PATH "Flex prefix")
    message(STATUS "Found Flex keg installed by Homebrew at ${BREW_FLEX_PREFIX}")
    set(FLEX_EXECUTABLE "${BREW_FLEX_PREFIX}/bin/flex" CACHE FILEPATH "Flex executable")
  endif()

  execute_process(
    COMMAND brew --prefix bash
    RESULT_VARIABLE BREW_BASH
    OUTPUT_VARIABLE BREW_BASH_PREFIX_TMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if (BREW_BASH EQUAL 0 AND EXISTS "${BREW_BASH_PREFIX_TMP}")
    set(BREW_BASH_PREFIX "${BREW_BASH_PREFIX_TMP}" CACHE PATH "Bash prefix")
    message(STATUS "Found GNU bash keg installed by Homebrew at ${BREW_BASH_PREFIX}")
    set(GNU_BASH "${BREW_BASH_PREFIX}/bin/bash" CACHE FILEPATH "Bash executable")
  endif()

# Suppress superfluous randlib warnings about "*.a" having no symbols on MacOSX.
  set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
  set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")

  set(CMAKE_CXX_FLAGS "-DTARGET_OS_SIMULATOR=0 -DTARGET_OS_IPHONE=0")

  set(BUILD_CMAKE_ARGUMENTS -DCMAKE_PREFIX_PATH=${BUILD_CMAKE_PREFIX_PATH}
                            -DOPENSSL_ROOT_DIR=${BUILD_OPENSSL_ROOT_DIR}
                            -DBISON_EXECUTABLE=${BISON_EXECUTABLE}
                            -DFLEX_EXECUTABLE=${FLEX_EXECUTABLE}
  )

endif()
