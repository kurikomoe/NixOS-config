{pkgs, ...}: let
  kustom-edge = pkgs.microsoft-edge.override {
    commandLineArgs = "--ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3";
  };
in {
  home.packages = with pkgs; [
    kustom-edge
  ];
}
