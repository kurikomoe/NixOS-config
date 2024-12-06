{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    arion
  ];

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };

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
  };
}
