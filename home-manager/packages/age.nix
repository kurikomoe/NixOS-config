{ config, inputs, lib, root, ... }:

let
  home = config.home.homeDirectory;
  xdg_config = config.xdg.configHome;

  res = "../res";
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

    secrets = {
      # ----------------------------------------------------------
      "gnupg/private.pgp".file = ../res/gnupg/private.pgp.age;
      "gnupg/public.pgp".file = ../res/gnupg/public.pgp.age;

      # ----------------------------------------------------------
      "ssh/config".file = ../res/ssh/config.age;

      "ssh/id_rsa".file = ../res/ssh/id_rsa.age;
      "ssh/id_rsa.pub".file = ../res/ssh/id_rsa.pub.age;

      "ssh/id_ed25519".file = ../res/ssh/id_ed25519.age;
      "ssh/id_ed25519.pub".file = ../res/ssh/id_ed25519.pub.age;

      "ssh/id_ed25519_age.pub".file = ../res/ssh/id_ed25519_age.pub.age;

      # ----------------------------------------------------------
      "gh/hosts.yml".file = ../res/gh/hosts.yml.age;
    };
  };

  # https://github.com/ryantm/agenix/issues/50#issuecomment-1926893522
  home.activation.agenix = lib.hm.dag.entryAnywhere config.systemd.user.services.agenix.Service.ExecStart;
}
