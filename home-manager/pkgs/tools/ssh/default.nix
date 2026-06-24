params @ {
  root,
  pkgs,
  inputs,
  config,
  kutils,
  lib,
  ...
}: let
  common = import ./common.nix params;

  files = {
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = kutils.age.buildAgeSecretsFileList files;
in
  lib.recursiveUpdate common {
    age.secrets = age_secrets_filelist;

    programs = lib.recursiveUpdate common.programs {};

    services = {
      # ssh-agent.enable = true;  # use gpg-agent's ssh function
    };

    # home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["linkGeneration"] ''
    #   run cat $HOME/.ssh/*.pub >> $HOME/.ssh/authorized_keys
    # '';
  }
