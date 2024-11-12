{
  config,
  pkgs,
  inputs,
  lib,
  customVars,
  ...
}: let
  configDir = "${config.xdg.configHome}";
  ghConfigDir = "${configDir}/gh";
  gitConfigDir = "${configDir}/git";
  gitExtraConfigPath = "${gitConfigDir}/config_extra";
in {
  home.packages = with pkgs; [
    git-lfs
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = customVars.usernameFull;
      userEmail = customVars.userEmail;
      signing = {
        key = "B6CF5D8D8ED4D90ED1D830922D6BAAE3F96083D2";
        signByDefault = true;
      };
      includes = [
        {path = ./gitconfig;}
      ];
    };

    gh = {
      enable = true;
      # settings.git_protocol = "git";
    };
  };

  home.shellAliases = {
    # Git
    gst = "git status";
    gi = "git ignore";
  };

  age.secrets."gh/hosts.yml".path = "${ghConfigDir}/hosts.yml";
}
