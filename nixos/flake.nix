{
  description = "A template that shows all standard flake outputs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";

    # nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";

    nur.url = "github:nix-community/NUR";

    # Move home-manager to standalone edition
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # --------------------- Third Party inputs ---------------------
    nix-alien.url = "github:thiagokokada/nix-alien";

    nixos-vscode-server.url = "https://github.com/msteen/nixos-vscode-server/tarball/master";

    # --------------------- Tmux Plugins ---------------------
    tmux-themepack = {
      url = "github:jimeh/tmux-themepack/master";
      flake = false;
    };

    # --------------------- Secrets Management ---------------------
    agenix.url = "github:ryantm/agenix";
  };

  # Outputs
  outputs = inputs@{ self, flake-parts, nixpkgs, ... }:
  let
    # setup pkgs here to avoid duplications in each device.
    # ----------------- helper functions ------------------
    lib = nixpkgs.lib;
    utils = import ../common/utils.nix { };
    cImport = utils.customNixPkgsImport;

    # -------------- pkgs versions ------------------
    versionMap = {
      "stable" = {
        nixpkgs = inputs.nixpkgs;
      };
      "unstable" = {
        nixpkgs = inputs.nixpkgs-unstable;
      };
    };

    allRepos = {
      "x86_64-linux" = rec {
        pkgs-stable = cImport inputs.nixpkgs {};
        pkgs-unstable = cImport inputs.nixpkgs-unstable {};

        pkgs-nur = import inputs.nur {
          pkgs = pkgs-stable;
          nurpkgs = pkgs-unstable;
        };

        cuda = {
          "12.2" = cImport inputs.nixpkgs-cuda-12_2 { cudaSupport = true; };
          "12.4" = cImport inputs.nixpkgs-cuda-12_4 { cudaSupport = true; };
        };
      };
    };

    devices = [
      devices/KurikoG14.nix
    ];
  in
    builtins.foldl'
      (acc: device:
        lib.recursiveUpdate acc (import device {
          inherit inputs allRepos versionMap;
          root = self;
        })
      )
      {} devices;
}
