{
  inputs,
  root,
  allRepos,
  versionMap,
  ...
}: let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    hostName = "KurikoArch";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

  utils = import "${root.base}/common/utils.nix" {inherit system;};
  repos = allRepos.${system};

  # =========== change this to switch version ===========
  hm-version = "stable";
  # ====================================================

  nixpkgs-hm = versionMap.${hm-version}.nixpkgs;
  pkgs-hm = repos."pkgs-${hm-version}";
  home-manager = versionMap.${hm-version}.home-manager;
  # ====================================================

  hm-template = import "${root.hm}/template.nix" (with customVars; {
    inherit inputs root customVars repos;

    pkgs = pkgs-hm;

    stateVersion = "24.05";

    extraNixPkgsOptions = {
      cudaSupport = true;
    };

    modules = [
      (inputs@{pkgs, ...}: {
        imports =
          utils.buildImports root.hm-pkgs [
            "./shells/fish"

            "./devs/common.nix"
            "./devs/langs"

            "./libs/others.nix"

            "./libs/cuda.nix"

            "./apps/db/mongodb.nix"

            "./gui/fonts.nix"
            "./gui/browsers"
            "./gui/jetbrains.nix"

            # "./apps/podman.nix"
          ] ++ [
            (import ../../home-manager/pkgs/tools (inputs//{topgrade = false;}))
          ];

        home.packages = with pkgs; [
          # Test gui
          xorg.xeyes
          mesa-demos
          vulkan-tools
        ];
      })
    ];
  });
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-template;
  }
