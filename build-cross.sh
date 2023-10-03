 #!/bin/bash

NATIVE_LIB_DIR="native-build"
JNI_RESOURCSE_DIR="src/main/resources/jni"
LUA_VER="5.3"
OSX_SDK_VERSION="22.4"

## TODO Build arm for linux and windows
## TODO Check script results

echo "Buidling native libs"
native/shared-build-setup.sh $LUA_VER $OSX_SDK_VERSION

echo "Preparing libs for java"
native/prepare-java.sh $LUA_VER $NATIVE_LIB_DIR $JNI_RESOURCSE_DIR

echo "Building java lib"
./gradlew build

echo "Finished"
