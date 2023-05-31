#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

. $(dirname $0)/commons.sh

POSITIONAL=()
JOBS=8
BUILDDIR=

helpFunction() {
  print G "Usage:"
  print N "\t$0 <QT_source_folder> <destination_folder> [options]"
  print N ""
  print N "Build options:"
  print N "  -j, --jobs NUM   Parallelize build across NUM processes. (default: 8)"
  print N "  -b, --build DIR  Build in DIR. (default: <QT_source_folder>/build)"
  print N "  -h, --help       Display this message and exit."
  print N ""
  print N "Any other arguments will be passed to the Qt configure script."
  exit 0
}

print N "This script compiles Qt6 statically"
print N ""

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -j | --jobs)
    JOBS="$2"
    shift
    shift
    ;;
  -b | --build)
    BUILDDIR="$2"
    shift
    shift
    ;;
  -h | --help)
    helpFunction
    ;;
  *)
    POSITIONAL+=("$1")
    shift
    ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ $# -lt 2 ]]; then
  helpFunction
fi

[ -d "$1" ] || die "Unable to find the QT source folder."
SRCDIR=$(cd $1 && pwd)
shift

PREFIX=$1
shift

if [[ -z "$BUILDDIR" ]]; then
  BUILDDIR=$SRCDIR/build
fi

LINUX="
  -platform linux-clang \
  -openssl-runtime \
  -egl \
  -opengl es2 \
  -no-icu \
  -no-linuxfb \
  -bundled-xcb-xinput \
  -xcb \
"

MACOS="
  -appstore-compliant \
  -no-feature-qdbus \
  -no-dbus \
  -- \
  -DCMAKE_OSX_ARCHITECTURES='arm64;x86_64'
"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  print N "Configure for linux"
  PLATFORM=$LINUX
elif [[ "$OSTYPE" == "darwin"* ]]; then
  print N "Configure for darwin"
  PLATFORM=$MACOS
else
  die "Unsupported platform (yet?)"
fi

# Create the installation prefix, and convert to an absolute path.
mkdir -p $PREFIX
PREFIX=(cd $PREFIX && pwd)

print Y "Wait..."
mkdir -p $BUILDDIR
(cd $BUILDDIR && bash $SRCDIR/configure \
  $* \
  --prefix=$PREFIX \
  -opensource \
  -confirm-license \
  -release \
  -static \
  -strip \
  -silent \
  -nomake tests \
  -make libs \
  -sql-sqlite \
  -skip qt3d \
  -skip qtmultimedia \
  -skip qtserialport \
  -skip qtsensors \
  -skip qtgamepad \
  -skip qtwebchannel \
  -skip qtwebengine \
  -skip qtwebview \
  -skip qtandroidextras \
  -feature-imageformat_png \
  -qt-doubleconversion \
  -qt-libpng \
  -qt-zlib \
  -qt-pcre \
  -qt-freetype \
  $PLATFORM) || die "Configuration error."

print Y "Compiling..."
cmake --build $BUILDDIR --parallel $JOBS || die "Make failed"

print Y "Installing..."
cmake --install $BUILDDIR || die "Make install failed"

print G "All done!"
