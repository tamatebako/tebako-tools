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

def_ext_prj_t(LIBARCHIVE "3.7.9" "ed8b5732e4cd6e30fae909fb945cad8ff9cb7be5c6cdaa3944ec96e4a200c04c")

message(STATUS "Collecting libarchive - " v${LIBARCHIVE_VER} " at " ${LIBARCHIVE_SOURCE_DIR})

if(DEFINED OPENSSL_ROOT_DIR)
  set(OPENSSL_DIR_OPT "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}")
endif(DEFINED OPENSSL_ROOT_DIR)

set(CMAKE_ARGUMENTS -DCMAKE_INSTALL_PREFIX=${DEPS}
                    -DCMAKE_BUILD_TYPE=Release
                    -DBUILD_SHARED_LIBS:BOOL=OFF
                    -DENABLE_ACL:BOOL=OFF
                    -DENABLE_CNG:BOOL=OFF
                    -DENABLE_ICONV:BOOL=OFF
                    -DENABLE_LIBXML2:BOOL=OFF
                    -DENABLE_BZip2:BOOL=OFF
                    -DENABLE_CPIO:BOOL=OFF
                    -DENABLE_CAT:BOOL=OFF
                    -DENABLE_TAR:BOOL=OFF
                    -DENABLE_TEST:BOOL=OFF
                    -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
                    ${OPENSSL_DIR_OPT}
)

if(DEFINED TEBAKO_BUILD_TARGET)
  list(APPEND CMAKE_ARGUMENTS  -DCMAKE_C_FLAGS=--target=${TEBAKO_BUILD_TARGET})
  list(APPEND CMAKE_ARGUMENTS  -DCMAKE_EXE_LINKER_FLAGS=--target=${TEBAKO_BUILD_TARGET})
  list(APPEND CMAKE_ARGUMENTS  -DCMAKE_SHARED_LINKER_FLAGS=--target=${TEBAKO_BUILD_TARGET})
endif(DEFINED TEBAKO_BUILD_TARGET)

  # ...................................................................
  # libarchive is the module that creates the real pain here
  # Its shared version looks around to find  other shared libraries which
  # can do the real work. For example, if liblzma.so is found then libarchive
  # supports lzma encoding.
  # Static libary is compiled against predefined set of static archive libraries
  # at the time when binary distribution created. This is not necessarily the
  # set of libraries which is present at the system where this script is
  # executed.
  #
  # There are two options to fix it:
  #
  #   1) Build local version of libarchive.a
  #
  #   2) Use LIBARCHIVE_STATIC_LIBRARIES and LIBARCHIVE_STATIC_LDFLAGS that are
  #      set by pkg_check_modules(LIBARCHIVE IMPORTED_TARGET libarchive>=3.1.2)
  #
  # Method #1 is implemented here.
  # ...................................................................

if(${IS_MSYS})
  set(__LIBARCHIVE "${DEPS}/lib/libarchive_static.a")
else(${IS_MSYS})
  set(__LIBARCHIVE "${DEPS}/lib/libarchive.a")
endif(${IS_MSYS})

ExternalProject_Add(${LIBARCHIVE_PRJ}
  PREFIX "${DEPS}"
  URL https://www.libarchive.org/downloads/libarchive-${LIBARCHIVE_VER}.tar.xz
  URL_HASH SHA256=${LIBARCHIVE_HASH}
  DOWNLOAD_NO_PROGRESS true
  UPDATE_COMMAND ""
  CMAKE_ARGS ${CMAKE_ARGUMENTS}
  SOURCE_DIR ${LIBARCHIVE_SOURCE_DIR}
  BINARY_DIR ${LIBARCHIVE_BINARY_DIR}
  BUILD_BYPRODUCTS ${__LIBARCHIVE}
)

add_library(_LIBARCHIVE STATIC IMPORTED)
set_target_properties(_LIBARCHIVE PROPERTIES IMPORTED_LOCATION  ${__LIBARCHIVE})
add_dependencies(_LIBARCHIVE ${LIBARCHIVE_PRJ})
