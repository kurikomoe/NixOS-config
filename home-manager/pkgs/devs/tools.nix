{
  pkgs,
  repos,
  inputs,
  ...
}: let
in {
  home.packages = with pkgs; [
    # tools
    just
    pueue

    # View hex
    hexyl
    hexdump

    repos.pkgs-unstable.hexpatch
    # inputs.hevi
  ];
}
