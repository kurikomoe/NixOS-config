{ pkgs, ... }: let

in {
  home.packages = with pkgs; [
    podman
  ];
}
