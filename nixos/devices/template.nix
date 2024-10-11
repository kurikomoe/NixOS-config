p@{
  inputs,
  customVars,
  repos ? {},
  modules ? [],
  ...
}:

let
  # ----------------- helper functions ------------------
  utils = import ./utils.nix { inherit customVars; };
  customNixPkgsImport = utils.customNixPkgsImport;

  # ----------------- reimport inputs ------------------
  versionMap = {
    "stable" = {
      nixpkgs = inputs.nixpkgs;
    };
    "unstable" = {
      nixpkgs = inputs.nixpkgs-unstable;
    };
  };

  nixpkgs = versionMap.${customVars.currentVersion}.nixpkgs;

  # -------------- pkgs versions ------------------
  pkgs = customNixPkgsImport nixpkgs {};

  pkgs-stable = customNixPkgsImport versionMap."stable".nixpkgs {};

  pkgs-unstable = customNixPkgsImport versionMap."unstable".nixpkgs {};

  pkgs-nur = import inputs.nur {
    inherit pkgs;
    nurpkgs = customNixPkgsImport versionMap."unstable".nixpkgs {};
  };

  repos = p.repos // {
    inherit pkgs-stable pkgs-unstable pkgs-nur;
  };

  config = nixpkgs.lib.nixosSystem {
    specialArgs = {
       inherit customVars repos inputs;
    } // (inputs.specialArgs or {});

    modules = p.modules ++ [
      ../configuration.nix

      # -------------- basic settings ----------------
      ({config, lib, ... }: {
        nix.package = pkgs.nix;

        nix.settings = utils._commonNixPkgsConfig.settings // { };
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
in {
  nixosConfigurations.${customVars.hostName} = config;
}
