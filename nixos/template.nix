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
        inherit customVars repos inputs;
      }
      // (inputs.specialArgs or {});

    modules =
      p.modules
      ++ [
        # -------------- basic settings ----------------
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          boot.tmp.useTmpfs = false;

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
            binutils
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

          programs.nix-ld.enable = true;
        })

        # # -------------- enable nur ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [inputs.nur.overlay];
        }
      ];
  }
