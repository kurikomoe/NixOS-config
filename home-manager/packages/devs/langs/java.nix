p@{ pkgs, inputs, ... }:

let

in {
  home.packages = with pkgs; [
    jdk
    kotlin
  ];
}
