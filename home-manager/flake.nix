{
  description = "Home Manager configuration of kuriko";

  inputs = {
    # --------------------- Main inputs ---------------------
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-cuda-12_4.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
    nixpkgs-cuda-12_2.url = "github:nixos/nixpkgs/0cb2fd7c59fed0cd82ef858cbcbdb552b9a33465";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # --------------------- Third Party inputs ---------------------
    nix-alien.url = "github:thiagokokada/nix-alien";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server/master";

    # --------------------- Tmux Plugins ---------------------
    tmux-themepack = {
      url = "github:jimeh/tmux-themepack/master";
      flake = false;
    };
    tmux-current-pane-hostname = {
      url = "github:soyuka/tmux-current-pane-hostname/master";
      flake = false;
    };
  };

# ---------------------------------------------------------------------------

  outputs = inputs@{ self, ... }:
  let
    # -------------- custom variables --------------------
    system = "x86_64-linux";
    currentVersion = "stable";
    editor = "nvim";

    customVars = rec {
      inherit system currentVersion editor;
      hostName = "KurikoNixOS";

      userName = "kuriko";
      userNameFull = "KurikoMoe";

      userEmail = "kurikomoe@gmail.com";

      homeDirectory = /home/${userName};
    };


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

    pkgs = import versionMap.${currentVersion}.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    agenix = inputs.agenix;

    # -------------- pkgs versions ------------------
    pkgs-stable = import versionMap."stable".nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import versionMap."unstable".nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    repos = {
      inherit pkgs-stable pkgs-unstable;

      cuda = {
        "12.2" = import inputs.nixpkgs-cuda-12_2 {
          inherit system;
          config.allowUnfree = true;
        };
        "12.4" = import inputs.nixpkgs-cuda-12_4 {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };

  in
  with customVars;
  with versionMap.${currentVersion}; {
    homeConfigurations.${userName} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit customVars inputs;

        # locked pkgs
        inherit repos;

        # root_path
        root = "${self}";
      };

      modules = [
        # -------------- load agenix secrets ----------------
        {
          imports = [ ./home/age.nix ];
          home.packages = [ agenix.packages.${system}.default ];
        }

        # --------------- load home config ---------------
        ./home
      ];
    };
  };
}
