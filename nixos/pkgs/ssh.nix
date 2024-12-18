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
        PermitRootLogin = lib.mkForce "prohibit-password";
        PasswordAuthentication = false;
      };
    };
  };
}
