{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        projectName = "stormlib";
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Dependencies
            zlib
            bzip2

            # C++ Tools
            clang-tools
            cmake
            neocmakelsp

            # Zig Tools
            zig
            zls

            # Utilities
            basedpyright
            lua-language-server
            just
            just-lsp

            nixd
            nixfmt
          ];
        };
      }
    );
}
