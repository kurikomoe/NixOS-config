# User should install at least on window-manager
{
  pkgs,
  repos,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    # xorg.xsetroot
    # turbovnc
    wayvnc
  ];
}
