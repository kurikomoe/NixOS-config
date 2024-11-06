p@{inputs, pkgs, root, ...}:

let

in {
  imports = [
    "${root}/packages/libs/openssl.nix"
    # "${root}/packages/libs/musl.nix"

    ./buildsystems.nix
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

    dust     # du-dust
    fd       # find
    fend
    ripgrep  # search tools

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

  xdg.configFile."gdb/gdbinit".text = ''
    set debuginfod enabled on
    set auto-load safe-path /
  '';
}
