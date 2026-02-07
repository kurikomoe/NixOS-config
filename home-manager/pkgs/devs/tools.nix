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

    # Generate src pack
    repomix

    repos.pkgs-unstable.hexpatch
    # inputs.hevi
  ];
}
