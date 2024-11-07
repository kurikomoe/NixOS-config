{ pkgs, ... }:

let

in {
  home.packages = with pkgs; [

  ];

  programs.vscode = {
    enable = true;
  };
}
