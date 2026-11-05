#! /usr/bin/env sh

set -ex

# NetBSD and the other BSDs ship a non-GNU make as /usr/bin/make, so allow the
# caller to point us at GNU make. Defaults to plain "make" everywhere else.
MAKE=${MAKE:-make}

# The commits this fork is built and tested with, from the gnustep-swift
# repository's config/patched-stack.tsv.  Update them with its pins.
TOOLS_MAKE_PIN=246a322b48d05120fdda43907bf0cb4e08395d0b
LIBOBJC2_PIN=a722f10058850e14dd825a4081b672873e412c92
LIBDISPATCH_PIN=4ce40128f607a6eb7b58077a06b7464c1518a30d

install_gnustep_make() {
    echo "::group::GNUstep Make"
    cd $DEPS_PATH
    git clone -q https://github.com/danjboyd/tools-make.git
    cd tools-make
    git checkout -q ${TOOLS_MAKE_BRANCH:-$TOOLS_MAKE_PIN}
    MAKE_OPTS=
    if [ -n "$HOST" ]; then
      MAKE_OPTS="$MAKE_OPTS --host=$HOST"
    fi
    if [ -n "$RUNTIME_VERSION" ]; then
      MAKE_OPTS="$MAKE_OPTS --with-runtime-abi=$RUNTIME_VERSION"
    fi
    ./configure --prefix=$INSTALL_PATH --with-library-combo=$LIBRARY_COMBO --with-libdir=$LIBDIR $MAKE_OPTS || cat config.log
    $MAKE install

    echo Objective-C build flags:
    $INSTALL_PATH/bin/gnustep-config --objc-flags
    echo "::endgroup::"
}

install_libobjc2() {
    echo "::group::libobjc2"
    cd $DEPS_PATH
    git clone -q https://github.com/danjboyd/libobjc2.git
    cd libobjc2
    git checkout -q $LIBOBJC2_PIN
    git submodule sync
    git submodule update --init
    mkdir build
    cd build
    cmake \
      -DTESTS=off \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DGNUSTEP_INSTALL_TYPE=NONE \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PATH \
      -DEMBEDDED_BLOCKS_RUNTIME=ON \
      ../
    $MAKE install
    echo "::endgroup::"
}

install_libdispatch() {
    echo "::group::libdispatch"
    cd $DEPS_PATH
    git clone -q https://github.com/swiftlang/swift-corelibs-libdispatch libdispatch
    git -C libdispatch checkout -q $LIBDISPATCH_PIN
    mkdir libdispatch/build
    cd libdispatch/build
    cmake \
      -DBUILD_TESTING=off \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PATH \
      -DINSTALL_PRIVATE_HEADERS=1 \
      ../
    $MAKE install
    echo "::endgroup::"
}

mkdir -p $DEPS_PATH

# Allow the packages we install locally to have their pkg-config info found.
# NB. windows uses a semicolon rather than a colon as a path separator.
if [ x"$PKG_CONFIG_PATH" = x ]; then
  PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig
else
  if [ "$IS_WINDOWS_MSVC" != "true" -a "$IS_WINDOWS_MINGW" != "true" ]; then
    PKG_PATH_SEP=":"
  else
    PKG_PATH_SEP=";"
  fi
  PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig$PKG_PATH_SEP$PKG_CONFIG_PATH
fi

# Windows MSVC toolchain uses tools-windows-msvc scripts to install non-GNUstep dependencies;
# the MSYS2 toolchain uses Pacman to install non-GNUstep dependencies.
if [ "$LIBRARY_COMBO" = "ng-gnu-gnu" -a "$IS_WINDOWS_MSVC" != "true" -a "$IS_WINDOWS_MINGW" != "true" ]; then
    install_libobjc2
    # libdispatch is optional for gnustep-base and does not support every
    # platform we build on, so allow a workflow to opt out of it.
    if [ "$INSTALL_LIBDISPATCH" != "false" ]; then
        install_libdispatch
    fi
fi

install_gnustep_make
