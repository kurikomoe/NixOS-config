{ root, pkgs, inputs, config, lib, ... }:

let
  utils = import "${root}/home/utils.nix";

  files = {
    "ssh/config" = ".ssh/data/config";
    "ssh/id_rsa" = ".ssh/id_rsa";
    "ssh/id_rsa.pub" = ".ssh/id_rsa.pub";
    "ssh/id_ed25519" = ".ssh/id_ed25519";
    "ssh/id_ed25519.pub" = ".ssh/id_ed25519.pub";
  };

  age_secrets_filelist = utils.buildAgeSecretsFileList files;

in {
  home.packages = with pkgs; [
    p7zip
    autossh
  ];

  age.secrets = age_secrets_filelist;

  programs = {
    ssh = {
      enable = true;
      compression = true;
      addKeysToAgent = "yes";
      extraConfig = "";
      forwardAgent = true;
      includes = [
        "data/config"
      ];
      serverAliveInterval = 60;
    };
  };

  services = {
    ssh-agent.enable = true;
  };

  home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["linkGeneration"] ''
    run cat $HOME/.ssh/*.pub >> $HOME/.ssh/authorized_keys
  '';
}
