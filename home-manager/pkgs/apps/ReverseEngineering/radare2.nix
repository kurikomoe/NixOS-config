# Reverse Enginneering Tool
{pkgs, ...}: {
  imports = [
    ./frida.nix
  ];

  home.packages = with pkgs; [
    radare2
  ];
}
# Post Installation:
# r2pm -U
# r2pm -ci r2frida

