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
  lib = nixpkgs.lib

  agenix = inputs.agenix;

  # -------------- pkgs versions ------------------
  pkgs = customNixPkgsImport nixpkgs extraNixPkgsOptions;

  pkgs-stable = customNixPkgsImport versionMap."stable".nixpkgs extraNixPkgsOptions;

  pkgs-unstable = customNixPkgsImport versionMap."unstable".nixpkgs extraNixPkgsOptions;

  pkgs-nur = import inputs.nur {
    inherit pkgs;
    nurpkgs = customNixPkgsImport versionMap."unstable".nixpkgs extraNixPkgsOptions;
  };

  repos = lib.recursiveUpdate {
    inherit pkgs-stable pkgs-unstable pkgs-nur;
  } p.repos;

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
        nix.settings = lib.recursiveUpdate utils._commonNixPkgsConfig.settings { };
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

          nixdiff = ''
            echo ======= Current System Updates ==========
            nix store diff-closures /var/run/current-system \
              (find /nix/var/nix/profiles -name "system-*-link" | sort | tail -n2 | head -n1)

            echo ======= Current Home Manager Updates ==========
            nix store diff-closures ${config.home.homeDirectory}/.local/state/nix/profiles/home-manager \
              (find ${config.home.homeDirectory}/.local/state/nix/profiles -name "home-manager-*-link" | sort | tail -n2 | head -n1)
            nix store diff-closures ${config.home.homeDirectory}/.local/state/nix/profiles/profile \
              (find ${config.home.homeDirectory}/.local/state/nix/profiles -name "profile-*-link" | sort | tail -n2 | head -n1)

            echo "============= DONE ================="
          '';

          nixup = ''
            sudo true;
            nix flake update "${config.home.homeDirectory}/.nixos/nixos";
            nix flake update "${config.home.homeDirectory}/.nixos/home-manager";

            sudo nixos-rebuild --flake "${config.home.homeDirectory}/.nixos/nixos" switch;
            home-manager --flake "${config.home.homeDirectory}/.nixos/home-manager#${deviceName}" switch;

            nixdiff;
            echo "============= DONE ================="
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
