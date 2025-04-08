p @ {
  inputs,
  pkgs,
  root,
  repos,
  ...
}: let
in {
  imports = [
    "${root.hm-pkgs}/libs/openssl.nix"
    # "${root.hm-pkgs}/libs/musl.nix"

    ./buildsystems.nix
    ./tools.nix
    ./gdb

    # ./frameworks/tauri.nix
  ];

  age.secrets."cachix/cachix.dhall" = {
    file = "${root.base}/res/cachix/cachix.dhall.age";
    path = ".config/cachix/cachix.dhall";
  };

  home.packages = with pkgs; [
    # Shell Tools
    (lib.hiPrio binutils)

    # Let's replace it with rust!
    # coreutils-full
    (lib.hiPrio repos.pkgs-unstable.uutils-findutils)
    (lib.hiPrio repos.pkgs-unstable.uutils-diffutils)
    (lib.hiPrio repos.pkgs-unstable.uutils-coreutils-noprefix)

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

    # openapi
    openapi-generator-cli

    protobuf
    protoscope
  ];
}
