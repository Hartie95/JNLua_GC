LUA_VER=${1:-5.3}
NATIVE_LIB_DIR=${2:-native-build}
JNI_RESOURCSE_DIR=${3:-src/main/resources/jni}

echo "Preparing libs for java"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-windows-i686.dll" "$JNI_RESOURCSE_DIR/x86-windows.dll"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-windows-amd64.dll" "$JNI_RESOURCSE_DIR/amd64-windows.dll"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-linux-i686.so" "$JNI_RESOURCSE_DIR/x86-linux.so"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-linux-amd64.so" "$JNI_RESOURCSE_DIR/amd64-linux.so"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-macosx-amd64.dylib" "$JNI_RESOURCSE_DIR/amd64-mac.dylib"
cp "$NATIVE_LIB_DIR/libjnlua-$LUA_VER-macosx-arm64e.dylib" "$JNI_RESOURCSE_DIR/aarch64-mac.dylib"