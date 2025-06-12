{pkgs, ...}: let
in {
  home.packages = with pkgs; [];

  services.podman = {
    enable = true;
  };

  home.shellAliases = {
    docker = "podman";
  };
}
