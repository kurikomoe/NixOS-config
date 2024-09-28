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

in
with customVars; {
  nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {

    specialArgs = {
       inherit customVars repos inputs;
    };

    modules = p.modules ++ [
      ../configuration.nix

      # -------------- basic settings ----------------
      {
        nix.package = pkgs.nix;
        nix.settings = utils._commonNixPkgsConfig.settings;
        nixpkgs.config.allowUnfree = true;
      }

      # # -------------- enable nur ----------------
      {
        # This should be safe, since nur use username as namespace.
        nixpkgs.overlays = [ inputs.nur.overlay ];
      }

      # agenix.nixosModules.default

      #inputs.home-manager.nixosModules.home-manager {
      #   home-manager.useGlobalPkgs = true;
      #   home-manager.useUserPackages = true;

      #   home-manager.users.${username} = import ./home;

      #   home-manager.extraSpecialArgs = {
      #     inherit customVars;
      #     root = "${self}";
      #     inputs = self.inputs;
      #   };
      #}
    ];
  };
}
