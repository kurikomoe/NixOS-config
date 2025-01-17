{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    podman
  ];

  services.podman = {
    enable = true;
  };

  home.shellAliases = {
    docker = "podman";
  };
}
