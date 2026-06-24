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
    "ssh/config" = ".ssh/config.extra";
    "ssh/id_rsa" = ".ssh/id_rsa";
    "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = kutils.age.buildAgeSecretsFileList files;
in
  lib.recursiveUpdate common {
    imports = [
      ./helpers.nix
    ];

    age.secrets = age_secrets_filelist;

    programs = {
      ssh = {
        extraConfig = "";
        includes = [
          "config.extra"
        ];
      };
    };

    # home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["linkGeneration"] ''
    #   run cat $HOME/.ssh/*.pub >> $HOME/.ssh/authorized_keys
    # '';
  }
