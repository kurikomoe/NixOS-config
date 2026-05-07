{
  pkgs,
  root,
  config,
  kutils,
  repos,
  ...
}: let
  home = config.home.homeDirectory;
  helper = kutils.age.agehelper;
in {
  home.packages = with pkgs; [
    repos.pkgs-kuriko-nur.codex
    bubblewrap
    socat
  ];

  home.file = {};

  home.shellAliases = {};

  # age.secrets = age_secrets_filelist;
}
