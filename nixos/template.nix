p @ {
  inputs,
  root,
  customVars,
  repos,
  modules ? [],
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};
in
  with customVars; {
    specialArgs =
      {
        inherit root customVars repos inputs;
      }
      // (inputs.specialArgs or {});

    modules =
      p.modules
      ++ [
        ./pkgs/ssh.nix
        # -------------- basic settings ----------------
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          boot.tmp.useTmpfs = false;

          boot.kernel.sysctl = {
            "kernel.core_pattern" = "./core.%e.%p.%t";
          };

          nix = {
            package = repos.pkgs-unstable.nix;
            settings =
              utils._commonNixPkgsConfig.settings
              // {
                trusted-users = [username];
              };
          };

          environment.systemPackages = with pkgs; [
            openssl
            pkg-config

            home-manager
            (lib.hiPrio binutils)
            neovim
            vim
            wget
            curl
            htop
            which
            git

            tzdata

            inputs.nix-alien.packages.${system}.nix-alien
          ];

          programs = {
            nix-ld = {
              enable = true;
              libraries = with pkgs;
                []
                ++ (pkgs.steam.args.multiPkgs pkgs);
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
