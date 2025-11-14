BUILD_SHARED_LIBS:="true"

all: build

configure:
  zig build cdb

build: configure
  zig build 

