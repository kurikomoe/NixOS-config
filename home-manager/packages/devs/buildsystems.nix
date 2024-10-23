p@{ inputs, pkgs, ... }:

let

in {
  home.packages = with pkgs; [
    cmake
    xmake
    ninja
    autoconf
    gnumake
    meson

    automake

    pkg-config
    llvmPackages.bintools

    just

    clang-tools

    mold
  ];

}
