p @ {
  inputs,
  root,
  customVars,
  repos,
  kutils,
  modules ? [],
  ...
}: let
  system = customVars.system;
  lib = repos.pkgs.lib;
in
  with customVars; {
    specialArgs =
      {
        inherit root customVars repos inputs kutils;
      }
      // (inputs.specialArgs or {});

    modules =
      p.modules
      ++ [
        # inputs.nix-ld.nixosModules.nix-ld
        inputs.nur.modules.nixos.default

        # Use lix
        # inputs.lix-module.nixosModules.default

        ./pkgs/ssh.nix
        # -------------- basic settings ----------------
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          boot.tmp.useTmpfs = lib.mkDefault false;

          boot.kernelParams = [
            "audit=0"
            "net.ifnames=0"
            "mitigations=off"
          ];

          boot.kernel.sysctl = {
            "kernel.core_pattern" = "./core.%e.%p.%t";
          };

          nix = {
            # package = lib.mkDefault repos.pkgs-unstable.nix;
            # package = lib.mkDefault repos.pkgs-unstable.nixVersions.latest;
            # package = lib.mkDefault repos.pkgs-kuriko-nur.determinate-nix;
            settings =
              kutils._commonNixPkgsConfig.settings
              // {
                # download-buffer-size = 500000000;
                always-allow-substitutes = lib.mkDefault true;
                auto-optimise-store = lib.mkDefault true;
                trusted-users = [username];
              };
          };

          environment.systemPackages = with pkgs; [
            polkit

            openssl
            pkg-config

            home-manager

            (lib.hiPrio binutils)
            (lib.hiPrio repos.pkgs-unstable.uutils-findutils)
            (lib.hiPrio repos.pkgs-unstable.uutils-diffutils)
            (lib.hiPrio repos.pkgs-unstable.uutils-coreutils-noprefix)

            smartmontools

            neovim
            vim
            wget
            curl
            htop
            which
            git

            patchelf

            inputs.nix-alien.packages.${system}.nix-alien
          ];

          # i18n.supportedLocales = [
          #   "en_US.UTF-8/UTF-8"
          #   "zh_CN.UTF-8/UTF-8"
          #   "ja_JP.UTF-8/UTF-8"
          # ];
          # i18n.defaultLocale = "en_US.UTF-8/UTF-8";

          # services.envfs.enable = true;

          programs = {
            # Format nix outputs
            nh = {
              enable = true;
              # clean.enable = true;
              # clean.extraArgs = "--keep-since 14d --keep 5";
            };

            nix-ld = {
              enable = true;
              libraries = with pkgs; [
                stdenv.cc
                stdenv.cc.cc.lib
                openssl
                icu
                libz
                coreutils-full
              ];
            };
            zsh.enable = true;
            fish.enable = true;
          };

          # all /bin/bash to avoid headache
          systemd.tmpfiles.rules = lib.mkDefault [
            "L /bin/bash - - - - /run/current-system/sw/bin/bash"
          ];
        })

        # # -------------- enable nur ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [inputs.nur.overlays.default];
        }
      ];
  }
