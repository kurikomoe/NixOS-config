inputs@{ root, pkgs, config, lib, ... }:

let
  age_helper = import "${root}/../common/age-helper.nix";

  files = {
    "ssh/config-iprc" = ".ssh/data/config";
    "ssh/id_rsa" = ".ssh/id_rsa";
    "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = age_helper.buildAgeSecretsFileList files;

  default = (import ./default.nix) inputs;

  final = default // {
    age.secrets = age_secrets_filelist;

    home.packages = with pkgs; [
      autossh
    ];

    home.shellAliases = {
      ssh = "/usr/bin/ssh -F ~/.ssh/config";
    };

    home.sessionVariables = {
      GIT_SSH_COMMAND="/usr/bin/ssh -F ~/.ssh/config";
    };
  };

in final

