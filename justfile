dynamic:="true"

all: build

configure:
  zig build cdb

build: configure
  zig build -Ddynamic="{{dynamic}}"

test: build
  zig build test
