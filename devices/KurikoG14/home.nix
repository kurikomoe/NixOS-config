{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system inputs;};

  hm-template = import "${root.hm}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    stateVersion = "24.05";

    extraNixPkgsOptions = {
      cudaSupport = true;
    };

    extraSpecialArgs = {
      koptions = {
        topgrade.enable = true;
      };
    };

    modules = [
      ({pkgs, ...}: {
        # nixpkgs.overlays = [
        #   (final: prev: {
        #     fish = repos.pkgs-fish-test.fish;
        #   })
        # ];

        # nixpkgs.config.permittedInsecurePackages = [
        #   "dotnet-sdk-wrapped-6.0.136"
        #   "dotnet-sdk-6.0.136"
        #   "dotnet-sdk-6.0.428"
        #   "dotnet-runtime-6.0.36"
        # ];

        nix.settings.system-features = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
          "gccarch-x86-64-v3"
        ];

        imports =
          (utils.buildImports root.hm-pkgs [
            "wsl"

            "shells/fish"

            "devs/common.nix"

            "devs/langs"
            "devs/ide/jetbrains.nix"
            # "devs/ide/vscode/default.nix"
            "devs/ide/vscode/vscode-server.nix"

            "tools"
            "tools/ssh/complete.nix"
            "tools/ssh/helpers.nix"

            "libs/others.nix"

            "libs/cuda.nix"

            "apps/db/mongodb.nix"
            "apps/db/mariadb.nix"

            "gui/fonts.nix"
            "gui/browsers/firefox"
            "gui/jetbrains.nix"

            #./apps/podman.nix"

            "apps/ReverseEngineering/radare2.nix"
            "apps/ReverseEngineering/ghidra.nix"
            "apps/ReverseEngineering/frida.nix"
          ])
          ++ [
            "${root.base}/home-manager/pkgs/devs/langs/dotnet.nix"
          ];

        home.packages = with pkgs; [
          # Test gui
          xorg.xeyes
          mesa-demos
          vulkan-tools

          colmena
          nixos-anywhere

          deploy-rs

          qemu

          podman
        ];

        services.podman = {
          enable = true;
        };
      })
    ];
  });
in
  hm-template
