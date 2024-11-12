p @ {
  inputs,
  pkgs,
  ...
}: let
in {
  imports = [
    ../common.nix
  ];

  home.packages = with pkgs; [
    texliveFull
  ];
}
