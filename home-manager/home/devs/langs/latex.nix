p@{ inputs, pkgs, ... }:

let

in {
  imports = [
    ../build_systems.nix
  ];

  home.packages = with pkgs; [
    texliveFull
  ];
}
