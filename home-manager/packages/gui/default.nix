{ pkgs, ... }:

let

in {
  imports = [
    ./fonts.nix

    ./browsers

    ./jetbrains.nix

    ./vscode
  ];
}
