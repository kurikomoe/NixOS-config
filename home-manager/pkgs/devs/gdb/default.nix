{
  pkgs,
  repos,
  ...
}: let
in {
  home.packages = with pkgs; [
    gdb
    lldb

    # gdb ui
    # seer
    gdbgui
    repos.pkgs-kuriko-nur.pwndbg
    gef

    # tracing
    strace
    ltrace
    lurk

    # bug finder
    valgrind
    flawfinder
  ];

  home.enableDebugInfo = true;

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".config/gdb/nlohmann_json.gdb".source = ./nlohmann_json.gdb;
}
