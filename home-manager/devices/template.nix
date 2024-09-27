# customVars = {
#   deviceName
#   userName
#   userNameFull
#   userEmail
#   homeDirectory
#   currentVersion
# }

p@{
  inputs,
  root,
  customVars,
  modules ? [],
  repos ? {},
  stateVersion,
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
      home-manager = inputs.home-manager;
    };
    "unstable" = {
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
    };
  };

  nixpkgs = versionMap.${customVars.currentVersion}.nixpkgs;
  agenix = inputs.agenix;

  # -------------- pkgs versions ------------------
  pkgs = customNixPkgsImport nixpkgs {};

  pkgs-stable = customNixPkgsImport versionMap."stable".nixpkgs {};

  pkgs-unstable = customNixPkgsImport versionMap."unstable".nixpkgs {};

  pkgs-nur = import inputs.nur {
    inherit pkgs;
    nurpkgs = customNixPkgsImport versionMap."unstable".nixpkgs {};
  };

  repos = {
    inherit pkgs-stable pkgs-unstable pkgs-nur;
  } // p.repos;

in
with customVars;
with versionMap.${currentVersion};
{
  homeConfigurations.${customVars.deviceName} = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      inherit customVars inputs root;

      # locked pkgs
      inherit repos;
    };

    modules = modules ++ [
      # -------------- load agenix secrets ----------------
      {
        imports = [ ../packages/age.nix ];
        home.packages = [ agenix.packages.${system}.default ];
      }

      # -------------- enable nur ----------------
      {
        # This should be safe, since nur use username as namespace.
        nixpkgs.overlays = [ inputs.nur.overlay ];
        home.packages = [ ];
      }
      # ------------- others -------------
      {
        home.packages = [
          # inputs.nix-search.packages.${system}.default
          pkgs.nix-search-cli
        ];
      }
      # ------------ user nix settings --------------------
      ({config, inputs, ... }: {
        home.stateVersion = stateVersion;
        home.username = username;
        home.homeDirectory = homeDirectory;

        nix.package = pkgs.nix;
        nix.settings = utils._commonNixPkgsConfig.settings;

        nixpkgs.config.allowUnfree = true;

        xdg.enable = true;

        home.sessionVariables = {
          EDITOR = "nvim";
        };

        home.packages = with pkgs; [
          (lib.lowPrio vim)
          (lib.lowPrio neovim)
        ];

        home.shellAliases = {
          hm = "home-manager";
          hme = "$EDITOR ${config.xdg.configHome}/home-manager";
          hms = "home-manager switch";

          nxsearch = "nix search nixpkgs";
        };

        programs = {
          home-manager.enable = true;

          ssh = {
            enable = true;
            compression = true;
            forwardAgent = true;
          };

          fish = {
            enable = true;
          };
        };
        services = {};
      })
    ];
  };
}
