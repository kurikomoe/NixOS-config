{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    arion
    nvidia-docker
    nvidia-container-toolkit
  ];

  # ref: https://github.com/nix-community/NixOS-WSL/discussions/487#discussioncomment-11180666
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    daemon.settings = {
      features.cdi = true;
    };
  };

  # hardware = {
  #   graphics.enable32Bit = true;
  #
  #   nvidia = {
  #     modesetting.enable = true;
  #     nvidiaSettings = false;
  #     open = false;
  #   };
  #   nvidia-container-toolkit.enable = true;
  # };
  # services.xserver.videoDrivers = ["nvidia"];

  # podman = {
  #   enable = true;
  #   autoPrune.enable = true;
  # };

  # oci-containers ={
  #   backend = "podman";
  #   containers = {
  #     container-name = {
  #       image = "container-image";
  #       autoStart = true;
  #       ports = [ "127.0.0.1:1234:1234" ];
  #     };
  #   };
  # };

  system.activationScripts.script.text = ''
    source ${config.system.build.setEnvironment}
    ${pkgs.nvidia-docker}/bin/nvidia-ctk cdi generate --output="/etc/cdi/nvidia.yaml"
  '';
}
