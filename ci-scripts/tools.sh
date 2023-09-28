#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

: "${LOCAL_BUILDS:=/tmp/local_builds}"
: "${LOCAL_INSTALLS:=/opt}"
: "${CMAKE_VERSION:=3.26.5}"
: "${LIBARCHIVE_VERSION:=3.6.2}"
: "${ARCH:=linux-x86_64}"

install_cmake() {
  echo "Running install_cmake version ${CMAKE_VERSION} for ${ARCH}"
  local cmake_install=${LOCAL_BUILDS}/cmake
  mkdir -p ${cmake_install}
  pushd ${cmake_install}
  wget  https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-${ARCH}.sh
  chmod +x cmake-${CMAKE_VERSION}-${ARCH}.sh
  ./cmake-${CMAKE_VERSION}-${ARCH}.sh --skip-license --prefix=/usr
  popd
  rm -rf ${cmake_install}
}

build_and_install_libarchive() {
  echo "Running build_and_install_libarchive version $LIBARCHIVE_VERSION"
  local libarchive_build="$LOCAL_BUILDS/libarchive"
  mkdir -p "$libarchive_build"
  pushd "$libarchive_build"
  wget "https://github.com/libarchive/libarchive/releases/download/v$LIBARCHIVE_VERSION/libarchive-$LIBARCHIVE_VERSION.tar.xz"
  tar xf "libarchive-$LIBARCHIVE_VERSION.tar.xz"
  cd "libarchive-$LIBARCHIVE_VERSION"
  ./configure --prefix="$LOCAL_INSTALLS" --without-iconv --without-xml2 --without-expat
  make -j8
  make install
  popd
  rm -rf "$libarchive_build"
}

$@
