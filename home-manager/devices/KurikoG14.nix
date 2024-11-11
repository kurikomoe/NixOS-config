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
      ({config, inputs, lib, pkgs, repos, ...}: {
        imports = [
          ../packages/wsl

          ../packages/shells/fish

          ../packages/devs/common.nix
          ../packages/devs/langs

          ../packages/tools

          ../packages/libs/others.nix

          ../packages/libs/cuda.nix

          # ../packages/apps/podman.nix
          ../packages/apps/db/mongodb.nix

          ../packages/gui/fonts.nix
          ../packages/gui/browsers
          ../packages/gui/jetbrains.nix
        ];

        home.packages = with pkgs; [
          # Test gui
          xorg.xeyes
          mesa-demos
          vulkan-tools
        ];
      })
    ];
  })
