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

    pkg-config

    just

    clang-tools

    mold
  ];

}
