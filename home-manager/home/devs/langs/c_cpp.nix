
p@{ inputs, pkgs, ... }:

let

in {
  imports = [
    ../build_systems.nix
  ];

  home.packages = with pkgs; [
    # build systems
    cmake
    xmake
    meson
    autoconf

    ninja
    gnumake

    # gcc
    (hiPrio gcc)
    # gcc_multi

    musl

    # llvm
    clang
    # clang_multi
    clang-tools

    # asm
    nasm
    yasm

    # debugger
    gdb

    # libs
    vcpkg
    boost
  ];
}
