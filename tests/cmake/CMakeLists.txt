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

# Function to check if a variable is set (not empty)
function(check_variable_set VAR_NAME)
    if(NOT ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is not set.")
    endif()
endfunction()

# Function to check if a file/directory exists at the path specified by a variable
function(check_exists VAR_NAME TYPE)
    if(NOT EXISTS "${${VAR_NAME}}")
        if(TYPE STREQUAL "FILE")
            message(FATAL_ERROR "The file specified in ${VAR_NAME} does not exist: ${${VAR_NAME}}")
        elseif(TYPE STREQUAL "DIRECTORY")
            message(FATAL_ERROR "The directory specified in ${VAR_NAME} does not exist: ${${VAR_NAME}}")
        endif()
    endif()
endfunction()

message(STATUS "BREW_PREFIX: ${BREW_PREFIX}")
check_variable_set(BREW_PREFIX)
check_exists(BREW_PREFIX DIRECTORY)

message(STATUS "OPENSSL_ROOT_DIR: ${OPENSSL_ROOT_DIR}")
check_variable_set(OPENSSL_ROOT_DIR)
check_exists(OPENSSL_ROOT_DIR DIRECTORY)

message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
check_variable_set(CMAKE_PREFIX_PATH)
check_exists(CMAKE_PREFIX_PATH DIRECTORY)

message(STATUS "BREW_BISON_PREFIX: ${BREW_BISON_PREFIX}")
check_variable_set(BREW_BISON_PREFIX)
check_exists(BREW_BISON_PREFIX DIRECTORY)

message(STATUS "BREW_FLEX_PREFIX: ${BREW_FLEX_PREFIX}")
check_variable_set(BREW_FLEX_PREFIX)
check_exists(BREW_FLEX_PREFIX DIRECTORY)

message(STATUS "FLEX_EXECUTABLE: ${FLEX_EXECUTABLE}")
check_variable_set(FLEX_EXECUTABLE)
check_exists(FLEX_EXECUTABLE FILE)

message(STATUS "BREW_BASH_PREFIX: ${BREW_BASH_PREFIX}")
check_variable_set(BREW_BASH_PREFIX)
check_exists(BREW_BASH_PREFIX DIRECTORY)

message(STATUS "GNU_BASH: ${GNU_BASH}")
check_variable_set(GNU_BASH)
check_exists(GNU_BASH FILE)
