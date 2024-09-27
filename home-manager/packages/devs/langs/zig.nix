
p@{ pkgs, inputs, ... }:

let

in {
  home.packages = with pkgs; [
    zig
    zls
  ];
}
