{ pkgs, inputs, lib, ... }:

{
  home.packages = with pkgs; [
    dig
    lsof
    iftop

    # proxychains-ng

    caddy
    aria2
];
}
