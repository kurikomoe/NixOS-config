{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
