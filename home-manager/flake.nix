{
  description = "Home Manager configuration of kuriko";

  inputs = {
    # --------------------- Main inputs ---------------------
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    nixpkgs-cuda-12_4.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
    nixpkgs-cuda-12_2.url = "github:nixos/nixpkgs/0cb2fd7c59fed0cd82ef858cbcbdb552b9a33465";

    nur.url = "github:nix-community/NUR";

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

    # ----------------- helper functions ------------------
    _commonNixPkgsConfig = {
      allowUnfree = true;
      settings = rec {
        trusted-users = [ customVars.userName ];
        substituters = [
          https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
          https://mirrors.ustc.edu.cn/nix-channels/store
          https://mirror.sjtu.edu.cn/nix-channels/store
          https://cache.nixos.org
          https://nix-community.cachix.org
        ];
        trusted-substituters = substituters;
        trusted-public-keys = pkgs.lib.mkAfter [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # ----------------- reimport inputs ------------------
    customNixPkgsImport = src: extraConfig: import src {
      inherit system;
      config = _commonNixPkgsConfig;
    } // extraConfig;


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

    nixpkgs = versionMap.${currentVersion}.nixpkgs;
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

      cuda = {
        "12.2" = customNixPkgsImport inputs.nixpkgs-cuda-12_2 {};
        "12.4" = customNixPkgsImport inputs.nixpkgs-cuda-12_4 {};
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
        # ------------ user nix settings --------------------
        {
          nix.package = pkgs.nix;
          nix.settings = _commonNixPkgsConfig.settings;
        }
        # -------------- load agenix secrets ----------------
        {
          imports = [ ./home/age.nix ];
          home.packages = [ agenix.packages.${system}.default ];
        }

        # -------------- enable nur ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [ inputs.nur.overlay ];
          home.packages = [ ];
        }

        # --------------- load home config ---------------
        ./home
      ];
    };
  };
}
