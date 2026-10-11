{
  pkgs,
  root,
  config,
  kutils,
  repos,
  ...
}: let
in {
  programs.dsh = {
    enable = true;
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
