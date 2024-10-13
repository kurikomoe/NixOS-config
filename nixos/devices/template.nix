p@{
  inputs,
  root,
  customVars,
  versionMap,
  repos,
  modules ? [],
  ...
}:

let
  system = customVars.system;
  utils = import ../../common/utils.nix { inherit system; };

  version = customVars.version;

  nixpkgs = versionMap.${version}.nixpkgs;
  pkgs = repos."pkgs-${version}";

in with customVars; {
  nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit customVars repos inputs;
    } // (inputs.specialArgs or {});

    modules = p.modules ++ [
      ../configuration.nix

      # -------------- basic settings ----------------
      ({config, lib, ... }: {
        nix.package = pkgs.nix;

        nix.settings = utils._commonNixPkgsConfig.settings // {
          trusted-users = [ username ];
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
          # inputs.agenix.packages.${system}.default
        ];
      })

      # # -------------- enable nur ----------------
      {
        # This should be safe, since nur use username as namespace.
        nixpkgs.overlays = [ inputs.nur.overlay ];
      }

      # agenix.nixosModules.default

      # inputs.home-manager.nixosModules.home-manager {
      #   home-manager.useGlobalPkgs = true;
      #   home-manager.useUserPackages = true;

      #   home-manager.users.${username} = import ./home;

      #   home-manager.extraSpecialArgs = {
      #     inherit customVars;
      #     root = "${self}";
      #     inputs = self.inputs;
      #   };
      # }
    ];
  };
}
