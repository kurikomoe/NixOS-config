p@{ lib, config, inputs, nixpkgs, pkgs, modulesPath, customVars, ... }:

let

in {
  imports = [
    ./wsl

    ./shells/fish

    ./devs/common.nix
    ./devs/langs

    ./tools

    ./libs/others.nix
    ./libs/cuda.nix
  ];
}
