{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # tools
    just
    pueue
  ];
}
