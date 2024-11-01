
p@{ inputs, pkgs, ... }:

let

in {
  imports = [
    ../common.nix
  ];

  home.packages = with pkgs; [
    # gcc
    (hiPrio gcc)
    # gcc_multi
    # musl

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
