{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};

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
        nixpkgs.overlays = [
          (final: prev: {
            fish = repos.pkgs-fish-test.fish;
          })
        ];

        imports =
          utils.buildImports root.hm-pkgs [
            "./wsl"

            "./shells/fish"

            "./devs/common.nix"
            "./devs/langs"

            "./tools"

            "./libs/others.nix"

            "./libs/dotnet.nix"

            "./libs/cuda.nix"

            "./apps/db/mongodb.nix"
            "./apps/db/mariadb.nix"

            "./gui/fonts.nix"
            "./gui/browsers/firefox"
            "./gui/jetbrains.nix"

            # "./apps/podman.nix"
            "./apps/ReverseEngineering/radare2.nix"
            "./apps/ReverseEngineering/ghidra.nix"
            "./apps/ReverseEngineering/frida.nix"
          ]
          ++ [];

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
