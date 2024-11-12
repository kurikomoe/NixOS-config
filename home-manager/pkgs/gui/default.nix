{pkgs, ...}: let
in {
  imports = [
    ./fonts.nix

    ./browsers

    ./jetbrains.nix

    ./vscode
  ];

  home.packages = with pkgs; [
    vulkan-tools
    mesa-demos
  ];
}
