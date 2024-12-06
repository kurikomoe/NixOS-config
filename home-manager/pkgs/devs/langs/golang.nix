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
    goPath = ".local/share/go";
  };
}
