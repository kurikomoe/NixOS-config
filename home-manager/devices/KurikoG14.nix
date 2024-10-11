{ inputs, root, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;
    currentVersion = "unstable";

    deviceName = "KurikoG14";

    hostName = "KurikoNixOS";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

in let
  template = import ./template.nix;
  utils = import ./utils.nix { inherit customVars; };
  customNixPkgsImport = utils.customNixPkgsImport;

  repos = {
    cuda = {
      "12.2" = customNixPkgsImport inputs.nixpkgs-cuda-12_2 { cudaSupport = true; };
      "12.4" = customNixPkgsImport inputs.nixpkgs-cuda-12_4 { cudaSupport = true; };
    };
  };

  config = template (with customVars; {
    inherit inputs root customVars;
    inherit repos;

    stateVersion = "24.05";

    extraNixPkgsOptions = {
      cudaSupport = true;
    };

    modules = [
      ({config, inputs, lib, pkgs, ...}: {
        imports = [
          ../packages/wsl

          ../packages/shells/fish

          ../packages/devs/common.nix
          ../packages/devs/langs

          ../packages/tools

          ../packages/libs/others.nix

          ../packages/libs/cuda.nix
        ];
      })
    ];
  });

in config
