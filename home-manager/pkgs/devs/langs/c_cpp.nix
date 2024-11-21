p @ {
  inputs,
  pkgs,
  ...
}: let
in {
  imports = [
    ../common.nix
  ];

  home.packages = with pkgs; [
    # gcc
    (hiPrio gcc)
    # gcc_multi
    # musl

    flex
    bison

    # llvm
    clang
    # clang_multi
    clang-tools

    # asm
    nasm
    yasm

    # debugger
    gdb

    # bug finder
    valgrind
    flawfinder
    cppcheck

    python311Packages.lizard

    # libs
    vcpkg
  ];
}
