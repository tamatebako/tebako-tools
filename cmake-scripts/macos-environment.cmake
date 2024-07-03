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

  function(find_and_set_homebrew_prefix package_name executable_name)
    execute_process(
      COMMAND brew --prefix ${package_name}
      RESULT_VARIABLE BREW_${package_name}_RESULT
      OUTPUT_VARIABLE BREW_${package_name}_PREFIX_TMP
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (BREW_${package_name}_RESULT EQUAL 0 AND EXISTS "${BREW_${package_name}_PREFIX_TMP}")
      set(BREW_${package_name}_PREFIX "${BREW_${package_name}_PREFIX_TMP}" CACHE PATH "${package_name} prefix")
      message(STATUS "Found ${package_name} keg installed by Homebrew at ${BREW_${package_name}_PREFIX}")
      set(${executable_name} "${BREW_${package_name}_PREFIX}/bin/${package_name}" CACHE FILEPATH "${executable_name} executable")
    endif()
  endfunction()


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
  find_and_set_homebrew_prefix("bison" "BISON_EXECUTABLE")
  find_and_set_homebrew_prefix("flex" "FLEX_EXECUTABLE")
  find_and_set_homebrew_prefix("bash" "GNU_BASH")

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
