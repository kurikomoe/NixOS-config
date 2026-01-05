{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  lib = pkgs.lib;
  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};

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
          (kutils.buildImports root.hm-pkgs [
            "wsl"

            "wsl/wslg.nix"

            "shells/fish"

            "devs/common.nix"

            "devs/langs"
            # "devs/ide/jetbrains.nix"
            # "gui/jetbrains.nix"
            # "devs/ide/vscode/default.nix"
            "devs/ide/vscode/vscode-server.nix"

            "tools"
            "tools/ssh/complete.nix"
            "tools/ssh/helpers.nix"

            "tools/attic/attic-client.nix"
            "tools/attic/attic-server.nix"

            "libs/others.nix"

            "libs/cuda.nix"

            "apps/db/mongodb.nix"
            "apps/db/mariadb.nix"
            "apps/vnc/server.nix"

            "gui/fonts.nix"
            "gui/browsers/firefox"
            "gui/browsers/edge.nix"

            # "./apps/podman.nix"

            # "apps/ReverseEngineering/radare2.nix"
            # "apps/ReverseEngineering/ghidra.nix"
            # "apps/ReverseEngineering/frida.nix"
          ])
          ++ [
            "${root.base}/home-manager/pkgs/devs/langs/dotnet.nix"
          ];

        home.packages = with pkgs; [
          # Test gui
          xorg.xeyes
          mesa-demos
          vulkan-tools

          distrobox
          distrobox-tui

          gemini-cli-bin

          colmena
          nixos-anywhere

          # use the latest deploy to avoid a bug
          repos.pkgs-kuriko-nur.deploy-rs

          qemu

          (pkgs.callPackage "${root.pkgs}/home-manager/fix-wsl.nix" {})

          repos.pkgs-unstable.msedit

          repos.pkgs-kuriko-nur.doxx

          (lib.hiPrio (pkgs.writeShellScriptBin "nixup" ''
            sudo true
            nix flake update --flake "$HOME/.nixos";
            oss $@
          ''))
        ];
      })
    ];
  });
in
  hm-template
