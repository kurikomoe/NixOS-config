{
  inputs,
  root,
  lib,
  genRepos,
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

  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};
  repos = genRepos system;

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

    extraSpecialArgs = {
      koptions = {
        topgrade.enable = false;
      };
    };

    modules = [
      (inputs @ {
        pkgs,
        config,
        ...
      }: {
        disabledModules = [
          "services/networking/frp.nix"
        ];

        nixpkgs.config.permittedInsecurePackages = [
          "dotnet-sdk-wrapped-6.0.136"
          "dotnet-sdk-6.0.136"
          "dotnet-sdk-6.0.428"
          "dotnet-runtime-6.0.36"
        ];

        imports =
          kutils.buildImports root.hm-pkgs [
            "./shells/fish"

            "./devs/ide/vscode/vscode-server.nix"
            "./devs/ide/vscode/default.nix"

            "./devs/common.nix"
            "./devs/langs"

            "./libs/others.nix"

            "./libs/cuda.nix"

            "./apps/db/mongodb.nix"

            "./gui/fonts.nix"
            "./gui/browsers"
            "./gui/jetbrains.nix"

            "./tools/ssh/complete.nix"

            "./tools/attic/attic-client.nix"
            "./tools/attic/attic-server.nix"

            # "./apps/podman.nix"
          ]
          ++ [
            "${root.pkgs}/home-manager/frp.nix"
            (import "${root.hm}/pkgs/tools" (inputs // {topgrade = false;}))
          ];

        targets.genericLinux.enable = true;

        home.packages = with pkgs; [
          # overwrite the system nix
          repos.pkgs-unstable.nix

          # Test gui
          xorg.xeyes
          mesa-demos
          vulkan-tools

          colmena
          deploy-rs

          podman

          repos.pkgs-unstable.cherry-studio
        ];

        services.frp = {
          enable = true;
          role = "client";
          settings = config.age.secrets."frp/frpc-arch.toml".path;
        };

        services.podman = {
          enable = true;
        };
      })
    ];
  });
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-template;
  }
