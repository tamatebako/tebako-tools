# Copyright (c) 2023-2025 [Ribose Inc](https://www.ribose.com).
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

set(WITH_OPENSSL_BUILD ON)

execute_process(
  COMMAND "${DEPS}/bin/openssl" "version"
  RESULT_VARIABLE OPENSSL_RES
  OUTPUT_VARIABLE OPENSSL_VER_STR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(OPENSSL_RES EQUAL 0)
  string(REGEX MATCH "^OpenSSL ([1-9][.][0-9][.][0-9])" OPENSSL_VER_TMP ${OPENSSL_VER_STR})
  set(OPENSSL_VER ${CMAKE_MATCH_1})
  message(STATUS "Found OpenSSL version ${OPENSSL_VER} at ${DEPS}/bin/openssl")
  if((${OPENSSL_VER} VERSION_GREATER_EQUAL "1.1.0") AND (${OPENSSL_VER} VERSION_LESS "3.0.0"))
    set(WITH_OPENSSL_BUILD OFF)
  endif((${OPENSSL_VER} VERSION_GREATER_EQUAL "1.1.0") AND (${OPENSSL_VER} VERSION_LESS "3.0.0"))
endif(OPENSSL_RES EQUAL 0)

if(WITH_OPENSSL_BUILD)
  execute_process(
    COMMAND "openssl" "version"
    RESULT_VARIABLE OPENSSL_RES
    OUTPUT_VARIABLE OPENSSL_VER_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(OPENSSL_RES EQUAL 0)
    execute_process(
      COMMAND "which" "openssl"
      RESULT_VARIABLE OPENSSL_RES
      OUTPUT_VARIABLE OPENSSL_LOC
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT OPENSSL_RES EQUAL 0)
      set(OPENSSL_LOC "<unknown>")
    endif(NOT OPENSSL_RES EQUAL 0)

    string(REGEX MATCH "^OpenSSL ([1-9][.][0-9][.][0-9])" OPENSSL_VER_TMP ${OPENSSL_VER_STR})
    set(OPENSSL_VER ${CMAKE_MATCH_1})
    message(STATUS "Found OpenSSL version ${OPENSSL_VER} at ${OPENSSL_LOC}")
    if((${OPENSSL_VER} VERSION_GREATER_EQUAL "1.1.0") AND (${OPENSSL_VER} VERSION_LESS "3.0.0"))
      set(WITH_OPENSSL_BUILD OFF)
    endif((${OPENSSL_VER} VERSION_GREATER_EQUAL "1.1.0") AND (${OPENSSL_VER} VERSION_LESS "3.0.0"))
  endif(OPENSSL_RES EQUAL 0)
endif(WITH_OPENSSL_BUILD)

if(WITH_OPENSSL_BUILD)
  message(STATUS "Building OpenSSL 1.1.1w")
  def_ext_prj_g(OPENSSL "OpenSSL_1_1_1w")

  set(__LIBSSL "${DEPS}/lib/libssl.a")
  set(__LIBCRYPTO "${DEPS}/lib/libcrypto.a")

  ExternalProject_Add(${OPENSSL_PRJ}
    PREFIX ${DEPS}
    GIT_REPOSITORY "https://github.com/openssl/openssl.git"
    GIT_TAG ${OPENSSL_TAG}
    UPDATE_COMMAND ""
    SOURCE_DIR ${OPENSSL_SOURCE_DIR}
    BINARY_DIR ${OPENSSL_BINARY_DIR}
    CONFIGURE_COMMAND   ${GNU_BASH} -c "${OPENSSL_SOURCE_DIR}/config          \
                                                        --openssldir=${DEPS}  \
                                                        --prefix=${DEPS}"
    BUILD_BYPRODUCTS ${__LIBSSL} ${__LIBCRYPTO}
  )

endif(WITH_OPENSSL_BUILD)
