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
  extraNixPkgsOptions ? {},
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
  pkgs = customNixPkgsImport nixpkgs extraNixPkgsOptions;

  pkgs-stable = customNixPkgsImport versionMap."stable".nixpkgs extraNixPkgsOptions;

  pkgs-unstable = customNixPkgsImport versionMap."unstable".nixpkgs extraNixPkgsOptions;

  pkgs-nur = import inputs.nur {
    inherit pkgs;
    nurpkgs = customNixPkgsImport versionMap."unstable".nixpkgs extraNixPkgsOptions;
  };

  repos = {
    inherit pkgs-stable pkgs-unstable pkgs-nur;
  } // p.repos;

in
with customVars;
with versionMap.${currentVersion};
{
  homeConfigurations.${deviceName} = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      inherit customVars inputs root;

      # locked pkgs
      inherit repos;
    };

    modules = p.modules ++ [
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
      ({config, inputs, lib, ... }: {
        home.stateVersion = stateVersion;
        home.username = username;
        home.homeDirectory = homeDirectory;

        nix.package = pkgs.nix;
        nix.settings = utils._commonNixPkgsConfig.settings // { };
        nix.gc = lib.mkDefault {
          automatic = true;
          frequency = "weekly";
        };

        # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
        nix.extraOptions = ''
          !include ${config.age.secrets."nix/access-tokens".path}
        '';

        nixpkgs.config.allowUnfree = true;

        xdg.enable = true;

        home.file."${config.xdg.configHome}/current-home-packages".text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
            formatted;


        home.packages = with pkgs; [
          (lib.lowPrio vim)
          (lib.lowPrio neovim)
        ] ++ (p.packages or []);

        home.sessionVariables = {
          EDITOR = lib.mkDefault "nvim";
        };

        home.shellAliases = {
          hm = lib.mkDefault "home-manager";
          hme = lib.mkDefault "$EDITOR '${config.xdg.configHome}/home-manager'";
          hms = "home-manager --flake '${config.home.homeDirectory}/.nixos/home-manager#${deviceName}' switch";
          hmsdr = "home-manager --flake '${config.home.homeDirectory}/.nixos/home-manager#${deviceName}' switch --dry-run";
          hmcd = lib.mkDefault "cd '${config.xdg.configHome}/home-manager'";

          nixup = ''
            sudo true;
            nix flake update "${config.home.homeDirectory}/.nixos/nixos";
            nix flake update "${config.home.homeDirectory}/.nixos/home-manager";

            sudo nixos-rebuild --flake "${config.home.homeDirectory}/.nixos/nixos" test;
            home-manager --flake "${config.home.homeDirectory}/.nixos/home-manager#${deviceName}" switch --dry-run;

            sudo nixos-rebuild --flake "${config.home.homeDirectory}/.nixos/nixos" switch;
            home-manager --flake "${config.home.homeDirectory}/.nixos/home-manager#${deviceName}" switch;
          '';

          nixgc = ''
            sudo nix-collect-garbage --delete-older-than 7d
            nix-collect-garbage --delete-older-than 7d
          '';

          nxsearch = lib.mkDefault "nix search nixpkgs";
        };

        programs = lib.mkDefault {
          home-manager.enable = true;

          ssh = lib.mkDefault {
            enable = true;
            compression = true;
            forwardAgent = true;
          };

          fish = lib.mkDefault {
            enable = true;
          };
        };

        services = lib.mkDefault {};
      })
    ];
  };
}
