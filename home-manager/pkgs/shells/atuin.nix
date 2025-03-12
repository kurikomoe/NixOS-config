{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
  ];

  home.shellAliases = {
    at = "atuin";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      key_path = config.age.secrets."atuin/key".path;
      sync = {
        records = true;
      };
      auto_sync = true;
      sync_frequency = "5m";
    };
  };
}
