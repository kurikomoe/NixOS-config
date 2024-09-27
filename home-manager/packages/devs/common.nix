p@{inputs, pkgs, ...}:

let

in {
  imports = [
    ./buildsystems.nix
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
  ];
}
