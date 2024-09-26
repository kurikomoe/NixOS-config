p@{ pkgs, inputs, ... }:

let

in {
  home.packages = with pkgs; [
    mono
    dotnet-sdk_8
  ];
}
