inputs @ {
  root,
  pkgs,
  config,
  kutils,
  lib,
  ...
}: let
  files = {
    "ssh/config-iprc" = ".ssh/config.extra";
    "ssh/id_rsa" = ".ssh/id_rsa";
    "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = kutils.age.buildAgeSecretsFileList files;

  shellScripts = with pkgs; [
    (pkgs.writeShellScriptBin "ssh"
      ''
        LD_PRELOAD=/usr/lib64/libnss_ldap.so.2 \
          ${pkgs.openssh}/bin/ssh -F ~/.ssh/config $@
      '')
  ];

  default = (import ./default.nix) inputs;
in
  default
  // {
    age.secrets = age_secrets_filelist;

    home.packages = with pkgs;
      [
        autossh
        openssh
      ]
      ++ (map (e: (lib.hiPrio e)) shellScripts);

    home.sessionVariables = {};
  }
