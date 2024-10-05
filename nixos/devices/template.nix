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
    } // (inputs.specialArgs or {});

    modules = p.modules ++ [
      ../configuration.nix

      # -------------- basic settings ----------------
      ({config, lib, ... }: {
        nix.package = pkgs.nix;
        nix.settings = utils._commonNixPkgsConfig.settings // { };
        nixpkgs.config.allowUnfree = true;

        environment.etc."current-system-packages".text =
          let
            packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
            sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
            formatted;
      })

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
