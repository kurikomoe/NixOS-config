{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };
  };
}
