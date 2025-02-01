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
          ]
          ++ [
            "${root.pkgs}/frp.nix"
            (import ../../home-manager/pkgs/tools (inputs // {topgrade = false;}))
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
