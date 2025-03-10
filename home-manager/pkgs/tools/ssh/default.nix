{
  root,
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  # age_helper = import "${root.base}/common/age-helper.nix";
  # files = {
  # };
  # age_secrets_filelist = age_helper.buildAgeSecretsFileList files;
in {
  home.packages = with pkgs; [
    p7zip
    autossh
    sshpass
    expect
    mosh
  ];

  # age.secrets = age_secrets_filelist;

  programs = {
    ssh = {
      enable = true;
      compression = true;
      addKeysToAgent = "yes";
      extraConfig = "";
      forwardAgent = true;
      # includes = [
      #   "data/config"
      # ];
      serverAliveInterval = 60;
    };
  };

  services = {
    ssh-agent.enable = true;
  };

  home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["linkGeneration"] ''
    # run cat $HOME/.ssh/*.pub >> $HOME/.ssh/authorized_keys
  '';
}
