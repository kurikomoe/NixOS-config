{ config, inputs, lib, root, ... }:

let
  home = config.home.homeDirectory;
  xdg_config = config.xdg.configHome;

  secret_file = filepath: {
    ${filepath}.file = ../res/${filepath}.age;
  };
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age = {
    secretsDir = "${home}/.agenix";

    identityPaths = [
      "${home}/.ssh/id_ed25519_age"
    ];

    secrets = {}
      # ----------------------------------------------------------
      // secret_file("gnupg/private.pgp")
      // secret_file("gnupg/public.pgp")
      # ----------------------------------------------------------
      // secret_file("ssh/config")
      // secret_file("ssh/id_rsa")
      // secret_file("ssh/id_rsa.pub")
      // secret_file("ssh/id_ed25519")
      // secret_file("ssh/id_ed25519.pub")
      // secret_file("ssh/id_ed25519_age.pub")
      # ----------------------------------------------------------
      // secret_file("gh/hosts.yml")
      # ----------------------------------------------------------
      // secret_file("nix/access-tokens")
    ;
  };

  # https://github.com/ryantm/agenix/issues/50#issuecomment-1926893522
  home.activation.agenix = lib.hm.dag.entryAnywhere config.systemd.user.services.agenix.Service.ExecStart;
}
