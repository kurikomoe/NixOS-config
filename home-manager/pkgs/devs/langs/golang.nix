p @ {
  pkgs,
  config,
  inputs,
  ...
}: let
in {
  home.packages = with pkgs; [
  ];

  programs.go = {
    enable = true;
  };

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
    GOMODCACHE = "${config.home.homeDirectory}/.local/share/go/pkg/mod";
    GOCACHE = "${config.xdg.cacheHome}/go-build";
  };
}
