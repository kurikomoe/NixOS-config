# Common Shell Defininations

p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let
  autojump-rs = pkgs.stdenv.mkDerivation {
    name = "autojump-rs";
    src = inputs.autojump-rs;
    unpackPhase = ":";
    nativeBuildInputs = with pkgs; [ gzip ];
    installPhase = ''
      mkdir -p "$out/bin";
      # strange error, on nixos the autojump is $src
      # but on iprc the autoujump is located at $src/autojump
      test -f $src/autojump && cp $src/autojump "$out/bin/autojump";
      test -f $src && cp $src "$out/bin/autojump";
      chmod +x "$out/bin/autojump";
    '';
  };

in
{
  imports = [
    "${root}/packages/devs/common.nix"
  ];

  home.packages = with pkgs; [
    # replace vanilla autojump with autojump-rs
    (lib.hiPrio autojump-rs)
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
