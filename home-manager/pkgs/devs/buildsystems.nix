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
    (lib.lowPrio llvmPackages.bintools)

    just

    clang-tools

    mold
  ];
}
