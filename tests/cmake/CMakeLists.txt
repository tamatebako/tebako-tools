# Copyright (c) 2024, [Ribose Inc](https://www.ribose.com).
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

cmake_minimum_required(VERSION 3.15)
project(cmake-tests)


# Adjust the path to where your macos-environment.cmake is located
include("${CMAKE_CURRENT_LIST_DIR}/../../cmake-scripts/macos-environment.cmake")

message(STATUS "BREW_PREFIX: ${BREW_PREFIX}")
if(NOT BREW_PREFIX)
  message(FATAL_ERROR "BREW_PREFIX is not set.")
endif()
if(NOT EXISTS "${BREW_PREFIX}")
  message(FATAL_ERROR "The directory specified in BREW_PREFIX does not exist: ${BREW_PREFIX}")
endif()

message(STATUS "OPENSSL_ROOT_DIR: ${OPENSSL_ROOT_DIR}")
if(NOT OPENSSL_ROOT_DIR)
  message(FATAL_ERROR "OPENSSL_ROOT_DIR is not set.")
endif()
if(NOT EXISTS "${OPENSSL_ROOT_DIR}")
  message(FATAL_ERROR "The directory specified in OPENSSL_ROOT_DIR does not exist: ${OPENSSL_ROOT_DIR}")
endif()

message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
if(NOT CMAKE_PREFIX_PATH)
  message(FATAL_ERROR "CMAKE_PREFIX_PATH is not set.")
endif()
if(NOT EXISTS "${CMAKE_PREFIX_PATH}")
  message(FATAL_ERROR "The directory specified in CMAKE_PREFIX_PATH does not exist: ${CMAKE_PREFIX_PATH}")
endif()

message(STATUS "BREW_BISON_PREFIX: ${BREW_BISON_PREFIX}")
if(NOT BREW_BISON_PREFIX)
    message(FATAL_ERROR "BREW_BISON_PREFIX is not set.")
endif()
if(NOT EXISTS "${BREW_BISON_PREFIX}")
    message(FATAL_ERROR "The directory specified in BREW_BISON_PREFIX does not exist: ${BREW_BISON_PREFIX}")
endif()

message(STATUS "BISON_EXECUTABLE: ${BISON_EXECUTABLE}")
if(NOT BISON_EXECUTABLE)
    message(FATAL_ERROR "BISON_EXECUTABLE is not set.")
endif()
if(NOT EXISTS "${BISON_EXECUTABLE}")
    message(FATAL_ERROR "The file specified in BISON_EXECUTABLE does not exist: ${BISON_EXECUTABLE}")
endif()

message(STATUS "BREW_FLEX_PREFIX: ${BREW_FLEX_PREFIX}")
if(NOT BREW_FLEX_PREFIX)
    message(FATAL_ERROR "BREW_FLEX_PREFIX is not set.")
endif(NOT BREW_FLEX_PREFIX)
if(NOT EXISTS "${BREW_FLEX_PREFIX}")
    message(FATAL_ERROR "The directory specified in BREW_FLEX_PREFIX does not exist: ${BREW_FLEX_PREFIX}")
endif()

message(STATUS "FLEX_EXECUTABLE: ${BISON_EXECUTABLE}")
if(NOT FLEX_EXECUTABLE)
    message(FATAL_ERROR "FLEX_EXECUTABLE is not set.")
endif()
if(NOT EXISTS "${FLEX_EXECUTABLE}")
    message(FATAL_ERROR "The file specified in FLEX_EXECUTABLE does not exist: ${FLEX_EXECUTABLE}")
endif()

message(STATUS "BREW_BASH_PREFIX: ${BREW_BASH_PREFIX}")
if(NOT BREW_BASH_PREFIX)
    message(FATAL_ERROR "BREW_BASH_PREFIX is not set.")
endif()
if(NOT EXISTS "${BREW_BASH_PREFIX}")
    message(FATAL_ERROR "The directory specified in BREW_BASH_PREFIX does not exist: ${BREW_BASH_PREFIX}")
endif()

message(STATUS "GNU_BASH: ${GNU_BASH}")
if(NOT GNU_BASH)
    message(FATAL_ERROR "GNU_BASH is not set.")
endif()
if(NOT EXISTS "${GNU_BASH}")
    message(FATAL_ERROR "The file specified in GNU_BASH does not exist: ${GNU_BASH}")
endif()
