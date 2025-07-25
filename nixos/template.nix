p @ {
  inputs,
  root,
  customVars,
  repos,
  modules ? [],
  ...
}: let
  system = customVars.system;
  lib = repos.pkgs.lib;
  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};
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
            package = repos.pkgs-unstable.nix;
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
            nix-ld = let
              libs = with pkgs;
                [
                  stdenv.cc
                  stdenv.cc.cc.lib
                  openssl
                  icu
                  libz
                ]
                ++ (pkgs.steam.args.multiPkgs pkgs)
                ++ (pkgs.steam-run.args.multiPkgs pkgs);
            in {
              enable = true;
              libraries = libs;
            };
            zsh.enable = true;
            fish.enable = true;
          };
        })

        # # -------------- enable nur ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [inputs.nur.overlays.default];
        }
      ];
  }
