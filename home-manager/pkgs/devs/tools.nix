{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # tools
    just
    pueue

    # debugger
    gdb
    lldb

    # gdb ui
    # seer
    gdbgui

    strace
    ltrace
    lurk

    # bug finder
    valgrind
    flawfinder
  ];
}
