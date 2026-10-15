{
  pkgs,
  root,
  config,
  kutils,
  repos,
  ...
}: let
in {
  home.packages = with pkgs; [
    # repos.pkgs-kuriko-nur.dsh
    repos.pkgs-kuriko-nur.dsh-tui
  ];

  programs.dsh = {
    # conflicts with self built dsh
    enable = false;
    profiles.headless = {
      plugins = ["@deepseek-ai/dsh-base" "@deepseek-ai/dsh-headless"];
    };
    profiles.web = {
      plugins = ["@deepseek-ai/dsh-base" "@deepseek-ai/dsh-web-app"];
    };
    profiles.custom = {
      plugins = [
        "@deepseek-ai/dsh-base"
        # "github:someone/cool-plugin"          # build-time resolve
      ];
      # specsHash = "";               # pin the resolution
      # userPatchesFile = ./patches.yml;        # profile-level cordis.patch.yml
    };
    # homePatchesFile = ./home-patches.yml;     # -> ~/.dsh/cordis.patch.yml
    # settings = { ... };                     # seeds ~/.dsh/settings.yaml once
  };
}
