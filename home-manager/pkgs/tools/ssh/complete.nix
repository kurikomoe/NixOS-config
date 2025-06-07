params @ {
  root,
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  common = import ./common.nix params;
  age_helper = import "${root.base}/common/age-helper.nix";

  files = {
    "ssh/config" = ".ssh/config.extra";
    "ssh/id_rsa" = ".ssh/id_rsa";
    "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = age_helper.buildAgeSecretsFileList files;
in {
  imports = [
    ./helpers.nix
  ];

  home.packages = common.packages;

  age.secrets = age_secrets_filelist;

  programs = lib.recursiveUpdate common.programs {
    ssh = {
      extraConfig = "";
      includes = [
        "config.extra"
      ];
    };
  };

  services = {
    ssh-agent.enable = true;
  };

  # home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["linkGeneration"] ''
  #   run cat $HOME/.ssh/*.pub >> $HOME/.ssh/authorized_keys
  # '';
}
