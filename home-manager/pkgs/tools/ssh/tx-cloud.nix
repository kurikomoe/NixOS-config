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
    # "ssh/config" = ".ssh/data/config";
    # "ssh/id_rsa" = ".ssh/id_rsa";
    # "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    # "ssh/id_ed25519" = ".ssh/id_ed25519";
    # "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = kutils.age.buildAgeSecretsFileList files;
in
  lib.recursiveUpdate common {
    age.secrets = age_secrets_filelist;

    programs = lib.recursiveUpdate common.programs {
      ssh = {
        includes = [
          "data/config"
        ];
      };
    };
  }
