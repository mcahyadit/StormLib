dynamic:="true"

all: build

clean:
  rm -rf .zig-cache/ zig-out/

configure:
  zig build cdb

build: configure
  zig build -Ddynamic="{{dynamic}}"

test: build
  zig build test
