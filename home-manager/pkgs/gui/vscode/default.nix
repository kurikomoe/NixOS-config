{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # vscode-fhs
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };
}
