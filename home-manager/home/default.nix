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

  # Basic PKGS Setups
  nixpkgs.config.allowUnfree = true;

  home.username = customVars.userName;
  home.homeDirectory = customVars.homeDirectory;

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    (lib.lowPrio vim)
    (lib.lowPrio neovim)
  ];

  home.shellAliases = {
    hm = "home-manager";
    hme = "vim $HOME/.config/home-manager";
    hms = "home-manager switch";

    nxsearch = "nix search nixpkgs";
  };

  programs = {
    home-manager.enable = true;

    ssh = {
      enable = true;
      compression = true;
      forwardAgent = true;
    };

    fish = {
      enable = true;
    };
  };


  services = {};

  home.stateVersion = "24.05";
}
