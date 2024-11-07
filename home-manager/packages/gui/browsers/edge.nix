{ pkgs, ... }:

let

in {
  home.packages = with pkgs; [
    microsoft-edge
  ];
}
