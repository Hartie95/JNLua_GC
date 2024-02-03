#!/bin/bash

TARGET_LUA_VERSION="${1:-5.3}"
OSX_SDK_VERSION="${2:-22.2}"

LINUX_COMPILER="gcc"
LINUX_STRIP="strip"
LINUX_ARM_COMPILER="arm-none-eabi-gcc"
LINUX_ARM_LD="arm-none-eabi-ld"
LINUX_ARM_STRIP="arm-none-eabi-strip"
LINUX_ARM_AR="arm-none-eabi-ar rcu"
LINUX_ARM_RANLIB="arm-none-eabi-ranlib"
LINUX_ARM64_COMPILER="aarch64-linux-gnu-gcc"
LINUX_ARM64_LD="aarch64-linux-gnu-ld"
LINUX_ARM64_STRIP="aarch64-linux-gnu-strip"
LINUX_ARM64_AR="aarch64-linux-gnu-ar rcu"
LINUX_ARM64_RANLIB="aarch64-linux-gnu-ranlib"
LINUX_LIB_SUFFIX="so"
LINUX_LUA_TYPE="posix"

MINGW_I686_COMPILER="i686-w64-mingw32-gcc"
MINGW_I686_STRIP="i686-w64-mingw32-strip"
MINGW_X86_64_COMPILER="x86_64-w64-mingw32-gcc"
MINGW_X86_64_STRIP="x86_64-w64-mingw32-strip"
MINGW_LIB_SUFFIX="dll"
MINGW_LUA_TYPE="mingw"

MAC_x86_64_COMPILER="o64-clang"
MAC_ARM64E_COMPILER="oa64e-clang"
MAC_x86_64_STRIP="x86_64-apple-darwin$OSX_SDK_VERSION-strip"
MAC_ARM64E_STRIP="arm64e-apple-darwin$OSX_SDK_VERSION-strip"
MAC_LIB_SUFFIX="dylib"
MAC_LUA_TYPE="posix"
MAC_x86_64_RANLIB="x86_64-apple-darwin$OSX_SDK_VERSION-ranlib"
MAC_x86_64_AR="x86_64-apple-darwin$OSX_SDK_VERSION-ar rcu"
MAC_x86_64_CODESIGN="x86_64-apple-darwin$OSX_SDK_VERSION-codesign_allocate"
MAC_ARM64E_RANLIB="arm64e-apple-darwin$OSX_SDK_VERSION-ranlib"
MAC_ARM64E_AR="arm64e-apple-darwin$OSX_SDK_VERSION-ar rcu"
MAC_ARM64E_CODESIGN="arm64e-apple-darwin$OSX_SDK_VERSION-codesign_allocate"

LINUX_LD_FLAGS="-static-libgcc"
WINDOWS_LD_FLAGS="-static"
MAC_LDFLAGS="-dynamic"

I686_CFLAGS="-fPIC -O2 -m32"
I686_LDFLAGS="-m32"

X86_64_CFLAGS="-fPIC -O2 -m64"
X86_64_LDFLAGS="-m64"

ARM64E_CFLAGS="-fPIC -O2"
ARM64E_LDFLAGS=""


function build () {
  lua_ver="$1"
  plat_type="$2"
  arch_type="$3"
  CC="$4"
  STRIP="$5"
  LIB_SUFFIX="$6"
  CFLAGS="$7"
  LDFLAGS="$8"
  LUA_TYPE="$9"

  AR="${10}"
  RANLIB="${11}"
  CODESIGN="${12}"

  LD="$CC"

  echo "preparing eris for $plat_type $arch_type"
  cd ../eris

  if [ "$lua_ver" == "5.2" ]; then
    JNLUA_SUFFIX="52"
    LUA_CFLAGS=""
    git checkout master
  else
    JNLUA_SUFFIX="53"
    LUA_CFLAGS="-DLUA_COMPAT_5_2"
    git checkout master-lua5.3
  fi

  echo "Building eris for $plat_type $arch_type"
  make clean -j$(nproc)

  if [ -n "$AR" ]; then
    make CC="$CC" CFLAGS="$CFLAGS $LUA_CFLAGS" LDFLAGS="$LDFLAGS" $LUA_TYPE -j$(nproc) LD="$LD" AR="$AR" RANLIB="$RANLIB"
  else
    make CC="$CC" CFLAGS="$CFLAGS $LUA_CFLAGS" LDFLAGS="$LDFLAGS" $LUA_TYPE -j$(nproc)
  fi

  echo "Building native for $plat_type $arch_type"

  cd ../native
  rm *.dll *.so *.dylib build/*.o

  CFLAGS="$CFLAGS -DJNLUA_USE_ERIS -DLUA_USE_POSIX" LDFLAGS="$LDFLAGS" ARCH=$arch_type JNLUA_SUFFIX="$JNLUA_SUFFIX" \
        LUA_LIB_NAME=lua LUA_INC_DIR=../eris/src LUA_LIB_DIR=../eris/src LIB_SUFFIX="$LIB_SUFFIX" \
        CC="$CC" LUA_VERSION="$lua_ver" PLATFORM=$plat_type \
        make -f Makefile libjnlua -j$(nproc)

  echo "prepare output for $plat_type $arch_type"

  LIB_FILE_NAME="libjnlua"$JNLUA_SUFFIX"."$LIB_SUFFIX
  TARGET_LIB_FILE_NAME="libjnlua-$lua_ver-$plat_type-$arch_type.$LIB_SUFFIX"
  cp $LIB_FILE_NAME ../native-debug/$TARGET_LIB_FILE_NAME
  "$STRIP" $LIB_FILE_NAME
  if [ -n "$CODESIGN" ]; then
    echo "codesigning $LIB_FILE_NAME"
    "$CODESIGN" -i $LIB_FILE_NAME -a $arch_type 64 -o $LIB_FILE_NAME.tmp
    mv $LIB_FILE_NAME.tmp $LIB_FILE_NAME
  fi
  mv $LIB_FILE_NAME ../native-build/$TARGET_LIB_FILE_NAME
  echo "done for $plat_type $arch_type"
}


echo "setup"

  mkdir -p native-build
  mkdir -p native-debug


  ## TODO replace with submodule
  if [ ! -d eris ]; then
    git clone https://github.com/MovingBlocks/eris
  fi


  cd native

## TODO build arm for linux and if possible windows
  ## Linux
build $TARGET_LUA_VERSION "linux" "i686" $LINUX_COMPILER $LINUX_STRIP $LINUX_LIB_SUFFIX "$I686_CFLAGS" "$I686_LDFLAGS $LINUX_LD_FLAGS" "$LINUX_LUA_TYPE"
build $TARGET_LUA_VERSION "linux" "amd64" $LINUX_COMPILER $LINUX_STRIP $LINUX_LIB_SUFFIX "$X86_64_CFLAGS" "$X86_64_LDFLAGS $LINUX_LD_FLAGS" "$LINUX_LUA_TYPE"
build $TARGET_LUA_VERSION "linux" "arm" $LINUX_ARM_COMPILER $LINUX_ARM_STRIP $LINUX_LIB_SUFFIX "$ARM64E_CFLAGS" "$ARM64E_LDFLAGS $LINUX_LD_FLAGS" \
"$LINUX_LUA_TYPE" "$LINUX_ARM_AR" "$LINUX_ARM_RANLIB"
build $TARGET_LUA_VERSION "linux" "aarch64" $LINUX_ARM64_COMPILER $LINUX_ARM64_STRIP $LINUX_LIB_SUFFIX "$ARM64E_CFLAGS" "$ARM64E_LDFLAGS $LINUX_LD_FLAGS" \
"$LINUX_LUA_TYPE" "$LINUX_ARM64_AR" "$LINUX_ARM64_RANLIB"

## Windows
build $TARGET_LUA_VERSION "windows" "i686" $MINGW_I686_COMPILER $MINGW_I686_STRIP $MINGW_LIB_SUFFIX "$I686_CFLAGS" "$I686_LDFLAGS $WINDOWS_LD_FLAGS" "$MINGW_LUA_TYPE"
build $TARGET_LUA_VERSION "windows" "amd64" $MINGW_X86_64_COMPILER $MINGW_X86_64_STRIP $MINGW_LIB_SUFFIX "$X86_64_CFLAGS" "$X86_64_LDFLAGS $WINDOWS_LD_FLAGS" "$MINGW_LUA_TYPE"

## Mac
build $TARGET_LUA_VERSION "macosx" "amd64" $MAC_x86_64_COMPILER $MAC_x86_64_STRIP $MAC_LIB_SUFFIX "$X86_64_CFLAGS" "$X86_64_LDFLAGS $MAC_LDFLAGS" \
  "$MAC_LUA_TYPE" "$MAC_x86_64_AR" "$MAC_x86_64_RANLIB" "$MAC_x86_64_CODESIGN"
build $TARGET_LUA_VERSION "macosx" "arm64e" $MAC_ARM64E_COMPILER $MAC_ARM64E_STRIP $MAC_LIB_SUFFIX "$ARM64E_CFLAGS" "$ARM64E_LDFLAGS $MAC_LDFLAGS" \
  "$MAC_LUA_TYPE" "$MAC_ARM64E_AR" "$MAC_ARM64E_RANLIB" "$MAC_ARM64E_CODESIGN"
