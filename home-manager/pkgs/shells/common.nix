# Common Shell Defininations
p @ {
  root,
  inputs,
  pkgs,
  lib,
  nixpkgs,
  ...
}: let
  autojump-rs = pkgs.stdenv.mkDerivation {
    name = "autojump-rs";
    src = pkgs.fetchzip {
      url = "https://github.com/xen0n/autojump-rs/releases/latest/download/autojump-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-wEdJQ9KHljCuJNYd5J15HYbtHW3d9aI5eBePdBBZaYQ=";
    };
    unpackPhase = ":";
    nativeBuildInputs = with pkgs; [gnutar gzip];
    installPhase = ''
      mkdir -p "$out/bin";
      cp $src/autojump "$out/bin/autojump";
      chmod +x "$out/bin/autojump";
    '';
  };
in {
  imports = [
    "${root.hm-pkgs}/devs/common.nix"
  ];

  home.packages = with pkgs; [
    # replace vanilla autojump with autojump-rs
    (lib.hiPrio autojump-rs)
    fzf
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/opt/bin"
  ];

  home.shellAliases = {
    # Others
    # j = "z";
  };

  programs = {
    dircolors = {
      enable = true;
      extraConfig = builtins.readFile ./common_data/dir_colors;
    };
    autojump = {
      enable = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
