{repos, ...}: let
  # kustom-edge = repos.pkgs-unstable.microsoft-edge.override {
  #   commandLineArgs = "--ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3";
  # };
  # Wait for https://github.com/NixOS/nixpkgs/blob/a79a11d6e6963d5eae73ababd20aa1d605f05666/pkgs/top-level/aliases.nix#L1225
  kustom-edge = repos.pkgs-kuriko-nur.microsoft-edge;
in {
  home.packages = [
    kustom-edge
  ];
}
