{ inputs, root, allRepos, versionMap, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    version = "stable";

    deviceName = "KurikoG14";

    hostName = "KurikoNixOS";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

  repos = allRepos.${system};

  template = import ./template.nix;
in
  template (with customVars; {
    inherit inputs root customVars versionMap repos;

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
  })
