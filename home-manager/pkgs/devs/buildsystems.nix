p @ {
  inputs,
  pkgs,
  ...
}: let
in {
  home.packages = with pkgs; [
    cmake
    xmake
    ninja
    autoconf
    gnumake
    meson

    scons

    automake
    libtool
    gnum4
    autogen
    autoreconfHook

    pkg-config
    llvmPackages.bintools

    just

    clang-tools

    mold
  ];
}
