# Common Shell Defininations

p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let

in
{
  imports = [
    "${root}/home/devs/common.nix"
  ];

  home.packages = with pkgs; [];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/opt/bin"
  ];

  home.shellAliases = {
    # Others
    j = "z";
  };

  home.file = {
    ".dir_colors".source = ./common_data/.dir_colors;
  };

  programs = {
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
