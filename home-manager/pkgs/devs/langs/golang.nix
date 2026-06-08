p @ {
  pkgs,
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
    GOPATH = "~/.local/share/go";
  };
}
