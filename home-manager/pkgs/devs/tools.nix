{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # tools
    just
    pueue

    # View hex
    hexyl
    hexdump
  ];
}
