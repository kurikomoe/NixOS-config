{
  lib,
  pkgs,
  repos,
  ...
}: let
in {
  home.packages = with pkgs; [
    stow
  ];
}
