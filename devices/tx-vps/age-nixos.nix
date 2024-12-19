{
  config,
  inputs,
  root,
  pkgs,
  lib,
  ...
}: let
  identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  secret_file = filepath: {
    "${filepath}".file = "${root.base}/res/${filepath}.age";
  };
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [inputs.agenix.packages.x86_64-linux.default];

  age = {
    inherit identityPaths;

    secrets =
      {}
      # ----------------------------------------------------------
      // secret_file "clash/config.m.yaml";
  };
}
