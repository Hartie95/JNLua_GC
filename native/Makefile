# Paths
JAVA_HOME?=/usr/lib/jvm/java-17-openjdk
LUA_LIB_DIR?=/usr/lib
LUA_VERSION?=5.3
JNLUA_SUFFIX?=53
LUA_INC_DIR?=/usr/include/lua$(LUA_VERSION)
LUA_LIB_NAME?=lua$(LUA_VERSION)
LIB_SUFFIX?=so
ARCH?=amd64
PLATFORM?=linux
CFLAGS?=-O2 -DLUA_USE_POSIX
LDFLAGS?=

# Tools
CC?=gcc
LD=$(CC)


# Default arguments
CFLAGS+=-c -fno-strict-aliasing -fPIC -Wall -DNDEBUG -D_REENTRANT -DJNLUA_SUFFIX=$(JNLUA_SUFFIX)
CFLAGS+=-I$(JAVA_HOME)/include -I$(LUA_INC_DIR)
LDFLAGS+=-shared -L$(LUA_LIB_DIR) -Wl
BASE_LIBS=-l$(LUA_LIB_NAME)

JNL_LIB_NAME=libjnlua$(JNLUA_SUFFIX).$(LIB_SUFFIX)
JVM_LIB_NAME=javavm.$(LIB_SUFFIX)

# Detect the host OS
ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    CUR_OS := Windows
else
    CUR_OS := $(shell uname)
endif

# Setup host os specific paths
ifeq ($(CUR_OS),Windows)
	CFLAGS+=-I$(JAVA_HOME)/include/windows
endif
ifeq ($(CUR_OS),Linux)
	CFLAGS+=-I$(JAVA_HOME)/include/linux
endif
ifeq ($(CUR_OS),Darwin)
	CFLAGS+=-I$(JAVA_HOME)/include/darwin
endif

# Setup args for the target platform
ifeq ($(PLATFORM),linux)
	LIB_PARAM=-soname=
endif
ifeq ($(PLATFORM),windows)
	LIB_PARAM=-soname=
endif
ifeq ($(PLATFORM),macosx)
	LIB_PARAM=-install_name,
endif

# Debug log output
$(info "")
$(info "Building on : $(CUR_OS)")
$(info "Target platform : $(PLATFORM) $(ARCH)")
$(info "Target Lua : $(LUA_VERSION)")
$(info "Target names : $(JNL_LIB_NAME) $(JVM_LIB_NAME)")
$(info "Compiler : $(CC)")
$(info "")



# Description blocks
all: libjnlua$(JNLUA_SUFFIX).$(LIB_SUFFIX) javavm.$(LIB_SUFFIX)
libjnlua: libjnlua$(JNLUA_SUFFIX).$(LIB_SUFFIX)

libjnlua$(JNLUA_SUFFIX).$(LIB_SUFFIX): build/jnlua.o
	$(LD) $(LDFLAGS),$(LIB_PARAM)$(JNL_LIB_NAME) -o$(JNL_LIB_NAME)  build/jnlua.o $(BASE_LIBS)

build/jnlua.o: jnlua.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -o build/jnlua.o jnlua.c

javavm.$(LIB_SUFFIX): build/javavm.o
	$(LD) $(LDFLAGS),$(LIB_PARAM)$(JVM_LIB_NAME) -o$(JVM_LIB_NAME) -L$(JAVA_HOME)/jre/lib/$(ARCH)/server build/javavm.o $(BASE_LIBS) -ljvm

build/javavm.o: javavm.c javavm.h
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -o build/javavm.o javavm.c

clean:
	-rm libjnlua$(JNLUA_SUFFIX).$(LIB_SUFFIX) build/jnlua.o
	-rm javavm.$(LIB_SUFFIX) build/javavm.o
