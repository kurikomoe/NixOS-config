# Common Shell Defininations

p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let

in
{
  imports = [
    "${root}/packages/devs/common.nix"
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

  programs = {
    dircolors = {
      enable = true;
      extraConfig = builtins.readFile ./common_data/dir_colors;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
