{ pkgs, inputs, lib, ... }:

{
  home.packages = with pkgs; [
    dig
    lsof
    iftop

    caddy
    aria2
];
}
