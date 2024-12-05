p @ {
  inputs,
  pkgs,
  root,
  ...
}: let
in {
  imports = [
    "${root.hm-pkgs}/libs/openssl.nix"
    # "${root.hm-pkgs}/libs/musl.nix"

    ./buildsystems.nix
    ./tools.nix
    # ./frameworks/tauri.nix
  ];

  home.packages = with pkgs; [
    # Shell Tools
    binutils
    coreutils-full

    asdf-vm

    wget
    curl

    htop
    which

    dust # du-dust
    fd # find
    fend
    ripgrep # search tools

    # compress
    p7zip
    zip
    xz
    unzip
    rar
    gzip

    # Git
    git
    git-ignore

    # dev
    devenv
    direnv
    cachix

    gdb
  ];

  home.enableDebugInfo = true;

  home.file.".gdbinit".text = ''
    set disassembly intel
    set debuginfod enabled on
    set auto-load safe-path /

    define rr
      r &> out.log
    end
  '';
}
