#! /bin/bash
# Copyright (c) 2022-2024, [Ribose Inc](https://www.ribose.com).
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

if [[ "$OSTYPE" == "darwin"* ]]; then
  GNU_SED="gsed"
else
  GNU_SED="sed"
fi

# ....................................................
restore_and_save() {
  echo "Patching $1"
  test -e "$1.old" && cp -f "$1.old" "$1"
  cp -f "$1" "$1.old"
}

do_patch() {
  restore_and_save "$1"
#  echo "$GNU_SED" -i "s/$2/$3/g" "$1"
  "$GNU_SED" -i "s/$2/$3/g" "$1"
}

do_patch_multiline() {
  restore_and_save "$1"
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1"
}

defined_win32_to_msc_ver() {
  re="defined(_WIN32)"
  sbst="defined(_MSC_VER) \/* tebako patched *\/ "
  do_patch "$1" "$re" "$sbst"

  re="#ifdef _WIN32"
  sbst="#ifdef _MSC_VER \/* tebako patched *\/ "
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

defined_n_win32_to_msc_ver() {
  re="!defined(_WIN32)"
  sbst="!defined(_MSC_VER) \/* tebako patched *\/ "
  do_patch "$1" "$re" "$sbst"

  re="#ifndef _WIN32"
  sbst="#ifndef _MSC_VER \/* tebako patched *\/ "
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

defined_el_win32_to_msc_ver() {
  re="#elif _WIN32"
  sbst="#elif _MSC_VER \/* tebako patched *\/ "
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

defined_msc_ver_to_win32() {
  re="defined(_MSC_VER)"
  sbst="defined(_WIN32) \/* tebako patched *\/ "
  do_patch "$1" "$re" "$sbst"

  re="#ifdef _MSC_VER"
  sbst="#ifdef _WIN32 \/* tebako patched *\/ "
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

funky_stdio_patch() {
  re="int pclose(FILE\* f)"
  sbst="int _folly_pclose(FILE* f) \/* tebako patched *\/"
  do_patch "$1" "$re" "$sbst"

  re="FILE\* popen(const char\* name, const char\* mode)"
  sbst="FILE* _folly_popen(const char* name, const char* mode) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"

  re="int vasprintf(char\*\* dest, const char\* format, va_list ap)"
  sbst="int _folly_vasprintf(char** dest, const char* format, va_list ap) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

funky_sysstat_patch() {
  re="int chmod(char const\* fn, int am)"
  sbst="int _folly_chmod(char const* fn, int am) \/* tebako patched *\/"
  do_patch "$1" "$re" "$sbst"

  re="int mkdir(const char\* fn, int mode)"
  sbst="int _folly_mkdir(const char* fn, int mode) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"

  re="int mkdir(const char\* fn, int \/\* mode \*\/)"
  sbst="int _folly_mkdir(const char* fn, int \/* mode *\/) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"

  re="int umask(int md)"
  sbst="int _folly_umask(int md) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

funky_string_patch() {
  re="int strcasecmp(const char\* a, const char\* b)"
  sbst="int _folly_strcasecmp(const char* a, const char* b) \/* tebako patched *\/"
  do_patch "$1" "$re" "$sbst"

  re="int strncasecmp(const char\* a, const char\* b, size_t c)"
  sbst="int _folly_strncasecmp(const char* a, const char* b, size_t c) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

funky_time_patch() {
  re="char\* asctime_r(const tm\* tm, char\* buf)"
  sbst="char* _folly_asctime_r(const tm* tm, char* buf) \/* tebako patched *\/"
  do_patch "$1" "$re" "$sbst"

  re="tm\* gmtime_r(const time_t\* t, tm\* res)"
  sbst="tm* _folly_gmtime_r(const time_t* t, tm* res) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"

  re="tm\* localtime_r(const time_t\* t, tm\* o)"
  sbst="tm* _folly_localtime_r(const time_t* t, tm* o) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1"
}

funky_formatter_patch() {
  re="if (!localtime_r(&unixTimestamp, &ltime)) {"
  sbst="if (!_folly_localtime_r(\&unixTimestamp, \&ltime)) { \/* tebako patched *\/"
  do_patch "$1" "$re" "$sbst"
}

if [[ "$OSTYPE" == "linux-musl"* ]]; then
# https://github.com/facebook/folly/issues/1478
  re="#elif defined(__FreeBSD__)"
  sbst="#elif defined(__FreeBSD__) || defined(__musl__)  \/* Tebako patched *\/"
  do_patch "$1/folly/debugging/symbolizer/Elf.cpp" "$re" "$sbst"

  restore_and_save "$1/CMake/FollyConfigChecks.cmake"
  re="FOLLY_HAVE_IFUNC"
  sbst="FOLLY_HAVE_IFUNC_NOT_PATCHED"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/CMake/FollyConfigChecks.cmake"

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

  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/CMake/FollyConfigChecks.cmake"

elif [[ "$OSTYPE" == "darwin"* ]]; then
  re="  set(OPENSSL_ROOT_DIR \"\/usr\/local\/opt\/openssl\" )"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
# -- Start of tebako patch --
 if (NOT OPENSSL_ROOT_DIR)
   set(OPENSSL_ROOT_DIR \"\/usr\/local\/opt\/openssl\")
 endif(NOT OPENSSL_ROOT_DIR)
# -- End of tebako patch --
EOM

  do_patch_multiline  "$1/CMakeLists.txt" "$re" "$sbst"

  re="set(OPENSSL_LIBRARIES \"\/usr\/local\/opt\/openssl\/lib\" )"
  sbst="set(OPENSSL_LIBRARIES \"\${OPENSSL_ROOT_DIR}\/lib\")    # tebako patched"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/CMakeLists.txt"

  re="set(OPENSSL_INCLUDE_DIR \"\/usr\/local\/opt\/openssl\/include\" )"
  sbst="set(OPENSSL_INCLUDE_DIR \"\${OPENSSL_ROOT_DIR}\/include\")    # tebako patched"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/CMakeLists.txt"

elif [[ "$OSTYPE" == "msys"* ]]; then
# --- folly/portability/Stdlib.h ---
  re="#define PATH_MAX _MAX_PATH"
  sbst="\/* #define PATH_MAX _MAX_PATH --- tebako patched *\/"
  do_patch "$1/folly/portability/Stdlib.h" "$re" "$sbst"

# --- folly/portability/Stdlib.cpp ---
  re="ret = mkdir(ptr, 0700);"
  sbst="ret = _folly_mkdir(ptr, 0700); \/* tebako patched *\/"
  do_patch "$1/folly/portability/Stdlib.cpp" "$re" "$sbst"

# --- folly/portability/SysTypes.h ---
  re="using pid_t = int;"
  sbst="\/* using pid_t = int; --- tebako patched *\/"
  do_patch "$1/folly/portability/SysTypes.h" "$re" "$sbst"

  re="using mode_t = unsigned int;"
  sbst="\/* using mode_t = unsigned int; --- tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/SysTypes.h"

  re="using uid_t = int;"
  sbst="using uid_t = short; \/* --- tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/SysTypes.h"

  re="using gid_t = int;"
  # shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
using gid_t = short; \/* --- tebako patched *\/
using nlink_t = short; \/* --- tebako patched *\/
EOM
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/folly/portability/SysTypes.h"

# --- folly/portability/SysStat.cpp ---
  funky_sysstat_patch "$1/folly/portability/SysStat.cpp"

# --- folly/portability/SysStat.h ---
  funky_sysstat_patch "$1/folly/portability/SysStat.h"

  re="#define S_IXUSR 0"
  # shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
\/* -- Start of tebako patch --
#define S_IXUSR 0
EOM
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/folly/portability/SysStat.h"

  re="#define S_ISREG(mode) (((mode) & (_S_IFREG)) == (_S_IFREG) ? 1 : 0)"
  # shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#define S_ISREG(mode) (((mode) \& (_S_IFREG)) == (_S_IFREG) ? 1 : 0)
*\/
#define	_S_IFLNK	0xA000
#define	S_IFLNK		_S_IFLNK
#define S_ISLNK(mode) (((mode) \& (_S_IFLNK)) == (_S_IFLNK) ? 1 : 0)

\/* -- End of tebako patch -- *\/
EOM
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/folly/portability/SysStat.h"

# --- folly/portability/SysTime.h ---
  re="int gettimeofday(timeval\* tv, folly_port_struct_timezone\*);"
  sbst="\/* int gettimeofday(timeval* tv, folly_port_struct_timezone*); --- tebako patched *\/"
  do_patch  "$1/folly/portability/SysTime.h" "$re" "$sbst"

# --- folly/FileUtil.cpp ---
  defined_msc_ver_to_win32 "$1/folly/FileUtil.cpp"
  re="(open,"
  sbst="(\/* tebako patched *\/ folly::portability::fcntl::open,"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="close(tmpFD)"
  sbst="\/* tebako patched *\/ folly::portability::unistd::close(tmpFD)"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="(close(fd))"
  sbst="(\/* tebako patched *\/ folly::portability::unistd::close(fd))"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="(read,"
  sbst="(\/* tebako patched *\/ folly::portability::unistd::read,"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="(write,"
  sbst="(\/* tebako patched *\/ folly::portability::unistd::write,"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="(dup,"
  sbst="(\/* tebako patched *\/ folly::portability::unistd::dup,"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

  re="(dup2,"
  sbst="(\/* tebako patched *\/ folly::portability::unistd::dup2,"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/FileUtil.cpp"

# --- folly/testing/TestUtil.cpp ---
  defined_win32_to_msc_ver "$1/folly/testing/TestUtil.cpp"
  re="dup("
  sbst="\/* tebako patched *\/ folly::portability::unistd::dup("
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/testing/TestUtil.cpp"

  re="dup2("
  sbst="\/* tebako patched *\/ folly::portability::unistd::dup2("
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/testing/TestUtil.cpp"

  re="lseek("
  sbst="\/* tebako patched *\/ folly::portability::unistd::lseek("
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/testing/TestUtil.cpp"

  re="(close("
  sbst="(\/* tebako patched *\/ folly::portability::unistd::close("
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/testing/TestUtil.cpp"

# --- folly/system/MemoryMapping.cpp ---
  re="0 == ftruncate("
  sbst="0 == \/* tebako patched *\/ folly::portability::unistd::ftruncate("
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/system/MemoryMapping.cpp"

# --- folly/portability/SysUio.cpp ---
  re="lseek(fd,"
  sbst=" \/* tebako patched *\/ folly::portability::unistd::lseek(fd,"
  do_patch  "$1/folly/portability/SysUio.cpp" "$re" "$sbst"

# --- folly/logging/ImmediateFileWriter.h ---
  re="isatty(file"
  sbst=" \/* tebako patched *\/ folly::portability::unistd::isatty(file"
  do_patch  "$1/folly/logging/ImmediateFileWriter.h" "$re" "$sbst"

# --- folly/logging/AsyncFileWriter.cpp ---
  re="isatty(file"
  sbst=" \/* tebako patched *\/ folly::portability::unistd::isatty(file"
  do_patch  "$1/folly/logging/AsyncFileWriter.cpp" "$re" "$sbst"

# --- folly/portability/Unistd.h ---
  re="#define X_OK F_OK"
  sbst="#define X_OK 1 \/* tebako patched *\/"
  do_patch  "$1/folly/portability/Unistd.h" "$re" "$sbst"

  re="int getuid();"
  sbst="uid_t getuid(); \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/Unistd.h"

  re="int getgid();"
  sbst="gid_t getgid(); \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/Unistd.h"

# --- folly/portability/Fcntl.cpp ---
  re="#include <folly\/portability\/Windows\.h>"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <folly\/portability\/Windows.h>
\/* -- Start of tebako patch -- *\/
#include <share.h>
\/* -- End of tebako patch -- *\/
EOM
  do_patch_multiline  "$1/folly/portability/Fcntl.cpp" "$re" "$sbst"

# --- folly/net/detail/SocketFileDescriptorMap.cpp --
  re="#include <fcntl\.h>"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <fcntl.h>

\/* -- Start of tebako patch -- *\/
#include <mutex>
\/* -- End of tebako patch -- *\/

EOM
  do_patch_multiline  "$1/folly/net/detail/SocketFileDescriptorMap.cpp" "$re" "$sbst"

  re="  __try {"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#ifndef __MINGW32__   \/* -- Tebako patched -- *\/
  __try {
EOM
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/folly/net/detail/SocketFileDescriptorMap.cpp"

  re="\/\/ We're at the core, we don't get the luxery of SCOPE_EXIT because"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#endif    \/* -- Tebako patched -- *\/
\/\/ We're at the core, we don't get the luxery of SCOPE_EXIT because
EOM
  "$GNU_SED" -i "s/$re/${sbst//$'\n'/"\\n"}/g" "$1/folly/net/detail/SocketFileDescriptorMap.cpp"

# --- folly/portability/Sockets.h ---
  restore_and_save "$1/folly/portability/Sockets.h"
  re="#ifdef _WIN32"

# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#ifdef _WIN32

\/* -- Start of tebako patch -- *\/
#ifdef __MINGW32__
  #include <mswsock.h>
  using cmsghdr = WSACMSGHDR;
  #define CMSG_SPACE WSA_CMSG_SPACE
#endif
\/* -- End of tebako patch -- *\/

EOM
  "$GNU_SED" -i -i "0,/$re/s||${sbst//$'\n'/"\\n"}|g" "$1/folly/portability/Sockets.h"

# --- folly/portability/Time.cpp ---
  funky_time_patch "$1/folly/portability/Time.cpp"

  re="(asctime_s(tmpBuf, tm))"
  sbst="(asctime_s(tmpBuf, 64\/* tebako patched *\/, tm))"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/Time.cpp"

# ---
  re="#if (defined(USE_JEMALLOC) || FOLLY_USE_JEMALLOC) && !FOLLY_SANITIZE"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
\/* -- Start of tebako patch -- *\/
#if defined(FOLLY_ASSUME_NO_JEMALLOC)
#undef USE_JEMALLOC
#undef FOLLY_USE_JEMALLOC
#endif
\/* -- End of tebako patch -- *\/
#if (defined(USE_JEMALLOC) || defined(FOLLY_USE_JEMALLOC)) \&\& !FOLLY_SANITIZE  \/* tebako patched *\/
EOM
  do_patch_multiline  "$1/folly/portability/Malloc.h" "$re" "$sbst"

# ---
  re="#include <folly\/Portability\.h>"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <folly\/Portability.h>
\/* -- Start of tebako patch -- *\/
#include <folly\/portability\/Malloc.h>
\/* -- End of tebako patch -- *\/

EOM
  do_patch_multiline  "$1/folly/memory/detail/MallocImpl.h" "$re" "$sbst"

# --- folly/system/ThreadName.cpp ---
  defined_win32_to_msc_ver "$1/folly/system/ThreadName.cpp"

  re="#if defined(__XROS__)"
  sbst="#if defined(__XROS__) || defined(__MINGW32__) \/* tebako patched *\/"
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/system/ThreadName.cpp"

# --- folly/net/NetOps.h ---

  re="#include <WS2tcpip\.h> \/\/ @manual"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <WS2tcpip.h> \/\/ @manual

\/* -- Start of tebako patch -- *\/
#ifdef __MINGW32__
  #include <memory>
  #include <mswsock.h>
#endif
\/* -- End of tebako patch -- *\/
EOM
  do_patch_multiline  "$1/folly/net/NetOps.h" "$re" "$sbst"

# --- folly/Random.cpp ---

  re="#include <folly\/synchronization\/RelaxedAtomic\.h>"
# shellcheck disable=SC2251
! IFS= read -r -d '' sbst << EOM
#include <folly\/synchronization\/RelaxedAtomic.h>

\/* -- Start of tebako patch -- *\/
#include <folly\/portability\/Fcntl.h>
\/* -- End of tebako patch -- *\/
EOM
  do_patch_multiline  "$1/folly/Random.cpp" "$re" "$sbst"

# --- folly/Utility.h ---
  re="T uninit;"
  sbst="T uninit = 0;  \/* tebako patched *\/"
  do_patch  "$1/folly/Utility.h" "$re" "$sbst"

# --- folly/portability/Unistd.cpp ---
  re="res = lseek64(fd, offset, whence);"
  sbst="res = folly::portability::unistd::lseek64(fd, offset, whence); \/* tebako patched *\/ "
  do_patch  "$1/folly/portability/Unistd.cpp" "$re" "$sbst"

  re="res = lseek(fd, offset, whence);"
  sbst="res = folly::portability::unistd::lseek(fd, offset, whence); \/* tebako patched *\/ "
  "$GNU_SED" -i "s/$re/$sbst/g" "$1/folly/portability/Unistd.cpp"

# --- folly/io/async/AsyncUDPSocket.cpp
  re="#elif _WIN32"
  sbst="#elif _MSC_VER \/* tebako patched *\/ "
  do_patch  "$1/folly/io/async/AsyncUDPSocket.cpp" "$re" "$sbst"

# ---
  defined_msc_ver_to_win32 "$1/folly/external/farmhash/farmhash.cpp"
  defined_msc_ver_to_win32 "$1/folly/detail/IPAddressSource.h"
  defined_msc_ver_to_win32 "$1/folly/portability/Sockets.cpp"

  defined_n_win32_to_msc_ver "$1/folly/portability/Dirent.h"
  defined_win32_to_msc_ver "$1/folly/portability/Dirent.cpp"

  funky_stdio_patch "$1/folly/portability/Stdio.h"
  funky_stdio_patch "$1/folly/portability/Stdio.cpp"
  funky_string_patch "$1/folly/portability/String.h"
  funky_string_patch "$1/folly/portability/String.cpp"
  funky_time_patch "$1/folly/portability/Time.h"
  funky_formatter_patch "$1/folly/logging/CustomLogFormatter.cpp"
  funky_formatter_patch "$1/folly/logging/GlogStyleFormatter.cpp"

# Note: the patch below comments out
#   int gettimeofday(timeval* tv, folly_port_struct_timezone*);
#   void timeradd(timeval* a, timeval* b, timeval* res);
#   void timersub(timeval* a, timeval* b, timeval* res);
# while gettimeofday is provided by MSys, the other two functions are lost
  defined_n_win32_to_msc_ver "$1/folly/portability/SysTime.h"
  defined_win32_to_msc_ver "$1/folly/portability/SysTime.cpp"
  defined_win32_to_msc_ver "$1/folly/lang/Exception.cpp"

  defined_el_win32_to_msc_ver "$1/folly/io/async/AsyncUDPSocket.cpp"
fi
