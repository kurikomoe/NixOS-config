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
    env = {
      GOPATH = "$HOME/.local/share/go";
    };
  };
}
