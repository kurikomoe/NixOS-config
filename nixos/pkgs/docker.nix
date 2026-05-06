{
  config,
  lib,
  pkgs,
  customVars,
  ...
}: let
  inherit (customVars) username;
in {
  environment.systemPackages = with pkgs; [
    arion
    podman-compose
    docker-compose
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      # enableNvidia = true;  # alert, kernel compile on wsl2
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.${username} = {
    # replace `<USERNAME>` with the actual username
    extraGroups = [
      "podman"
    ];
  };

  # virtualisation = {
  #   docker = {
  #     enable = true;
  #     autoPrune.enable = true;
  #   };
  #
  #   # podman = {
  #   #   enable = true;
  #   #   autoPrune.enable = true;
  #   # };
  #
  #   # oci-containers ={
  #   #   backend = "podman";
  #   #   containers = {
  #   #     container-name = {
  #   #       image = "container-image";
  #   #       autoStart = true;
  #   #       ports = [ "127.0.0.1:1234:1234" ];
  #   #     };
  #   #   };
  #   # };
  # };
}
