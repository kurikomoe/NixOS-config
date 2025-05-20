{
  description = "Home Manager configuration of kuriko";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    # --------------------- Main inputs ---------------------
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-fish-test.url = "github:NixOS/nixpkgs/pull/367229/head";

    # nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-24.11/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";
    # nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.11/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    nixpkgs-glibc-2_35-224.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager-glibc-2_35-224 = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs-glibc-2_35-224";
    };

    nixpkgs-cuda-12_4.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
    nixpkgs-cuda-12_2.url = "github:nixos/nixpkgs/0cb2fd7c59fed0cd82ef858cbcbdb552b9a33465";

    # GUI
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -------------------- tools ------------------
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    deploy-rs.url = "github:serokell/deploy-rs";

    # ------------------- Core inputs -------------------
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kuriko-nur = {
      url = "github:kurikomoe/nur-packages";
      # url = "git+file:///home/kuriko/.nur";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # ----------------- rust -----------------
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ------------------- utils ------------------
    flake-parts.url = "github:hercules-ci/flake-parts";

    # --------------------- Third Party inputs ---------------------
    nix-alien.url = "github:thiagokokada/nix-alien";

    # nix-ld.url = "github:Mic92/nix-ld";
    # nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # --------------------- Tmux Plugins ---------------------
    tmux-themepack = {
      url = "github:jimeh/tmux-themepack/master";
      flake = false;
    };
    tmux-current-pane-hostname = {
      url = "github:soyuka/tmux-current-pane-hostname/master";
      flake = false;
    };

    # -------------------- nix search --------------------
    nix-search.url = github:diamondburned/nix-search;

    # -------------------- vim plugins --------------------
    # omnisharp-vim = {
    #   url = "github:OmniSharp/omnisharp-vim";
    #   flake = false;
    # };

    # ------------------ common shell plugins --------------
    # move to fetch
    # autojump-rs = {
    #   type = "tarball";
    #   flake = false;
    #   url = "https://github.com/xen0n/autojump-rs/releases/latest/download/autojump-x86_64-unknown-linux-musl.tar.gz";
    # };

    # -------------------- fish plugins --------------------
    fishPlugin-fish-command-timer = {
      url = "github:jichu4n/fish-command-timer";
      flake = false;
    };
    fishPlugin-replay = {
      url = "github:jorgebucaran/replay.fish";
      flake = false;
    };
    fishPlugin-fish-ssh-agent = {
      url = "github:danhper/fish-ssh-agent";
      flake = false;
    };
    fishPlugin-autopair = {
      url = "github:jorgebucaran/autopair.fish";
      flake = false;
    };
    fishPlugin-puffer-fish = {
      url = "github:nickeb96/puffer-fish";
      flake = false;
    };
    fishPlugin-fish-abbreviation-tips = {
      url = "github:Gazorby/fish-abbreviation-tips";
      flake = false;
    };
    fishPlugin-theme-dracula = {
      url = "github:dracula/fish";
      flake = false;
    };

    # -------------------------------------------------------------
    hevi.url = "github:Arnau478/hevi";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-parts,
    devenv-root,
    ...
  }: let
    systems = [
      "x86_64-linux"
      # "aarch64-linux"
      #   "aarch64-darwin"
      # "x86_64-darwin"
    ];

    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;

    root = rec {
      base = self;
      pkgs = "${self}/pkgs";

      os = "${self}/nixos";
      os-pkgs = "${os}/pkgs";

      hm = "${self}/home-manager";
      hm-pkgs = "${hm}/pkgs";
    };

    versionMap = {
      "stable" = {
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };
      "unstable" = {
        nixpkgs = inputs.nixpkgs-unstable;
        home-manager = inputs.home-manager-unstable;
      };
      "iprc" = {
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };
    };

    kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};

    allRepos = forAllSystems (system: let
      cImport = kutils.customNixPkgsImport system;
    in rec {
      pkgs = pkgs-stable;
      pkgs-stable = cImport inputs.nixpkgs {};
      pkgs-unstable = cImport inputs.nixpkgs-unstable {};

      pkgs-fish-test = cImport inputs.nixpkgs-fish-test {};

      pkgs-nur = import inputs.nur {
        pkgs = pkgs-stable;
        nurpkgs = pkgs-unstable;
      };

      pkgs-kuriko-nur = import inputs.kuriko-nur {
        pkgs = pkgs-stable;
        # inputs = inputs.kuriko-nur.inputs;
      };

      agenix = import inputs.agenix {inherit system;};

      cuda = {
        "12.2" = cImport inputs.nixpkgs-cuda-12_2 {cudaSupport = true;};
        # "12.4" = cImport inputs.nixpkgs-cuda-12_4 {cudaSupport = true;};
      };
    });

    devices = [
      ./devices/KurikoG14
      ./devices/KurikoTB16+

      ./devices/KurikoArch

      ./devices/tx-vps

      ./devices/cpuserver58
      ./devices/iprc
    ];

    checksDeploy =
      builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      inputs.deploy-rs.lib;
    # checksDeploy = builtins.trace _checksDeploy.x86_64-linux.deploy-schema _checksDeploy;
  in
    builtins.foldl'
    (
      acc: device: (lib.recursiveUpdate acc (
        let
          config = let
            params = {inherit inputs root versionMap allRepos lib;};
            cfg = import "${device}" params;
          in
            builtins.trace "${device}: ${builtins.concatStringsSep "," (builtins.attrNames cfg)}" cfg;
        in
          config
      ))
    )
    rec {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      checks = lib.recursiveUpdate checksDeploy (forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = let
            pkgs = allRepos.${system}.pkgs-stable;
          in {
            alejandra.enable = true;
            trufflehog = {
              enable = true;
              entry = let
                script = pkgs.writeShellScript "precommit-trufflehog" ''
                  set -e
                  ${pkgs.trufflehog}/bin/trufflehog --no-update git "file://$(git rev-parse --show-toplevel)" --only-verified --fail
                '';
              in
                builtins.toString script;
            };
          };
        };
      }));

      devShells = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

        lib = nixpkgs.lib;
      in {
        default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

          packages = with pkgs; [
            (lib.hiPrio pkgs-unstable.uutils-findutils)
            (lib.hiPrio pkgs-unstable.uutils-diffutils)
            (lib.hiPrio pkgs-unstable.uutils-coreutils-noprefix)
          ];
        };
      });
    }
    devices;
}
