{
  inputs,
  pkgs,
  ...
}: let
in {
  home.packages = with pkgs; [
    # Depreatced
    # firefox-devedition-bin
    firefox-devedition
  ];
}
