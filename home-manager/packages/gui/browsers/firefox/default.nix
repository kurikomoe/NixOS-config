{ inputs, pkgs, ... }:

let

in {
  home.packages = with pkgs; [
    firefox-devedition
  ];
}
