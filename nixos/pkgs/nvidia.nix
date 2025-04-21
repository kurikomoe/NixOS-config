# This is for pure linux, not wsl
{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [];

  hardware = {
    graphics.enable32Bit = true;

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = false;
      open = false;
    };
    nvidia-container-toolkit.enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
}
