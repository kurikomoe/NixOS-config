{
  description = "Home Manager configuration of kuriko";

  inputs = {
    # --------------------- Main inputs ---------------------
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    # nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    nixpkgs-cuda-12_4.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
    nixpkgs-cuda-12_2.url = "github:nixos/nixpkgs/0cb2fd7c59fed0cd82ef858cbcbdb552b9a33465";

    nixpkgs-glibc-2_35-224.url = "github:nixos/nixpkgs/nixos-22.11";

    nixpkgs-nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur.url = "github:nix-community/NUR";

    # ------------------- Core inputs -------------------
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager-glibc-2_35-224 = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs-glibc-2_35-224";
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

    # -------------------- nix search --------------------
    nix-search.url = github:diamondburned/nix-search;

    # -------------------- vim plugins --------------------
    # omnisharp-vim = {
    #   url = "github:OmniSharp/omnisharp-vim";
    #   flake = false;
    # };

    # ------------------ common shell plugins --------------
    autojump-rs = {
      type = "tarball";
      flake = false;
      url = "https://github.com/xen0n/autojump-rs/releases/latest/download/autojump-x86_64-unknown-linux-musl.tar.gz";
    };

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
  };

  # ---------------------------------------------------------------------------

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs systems;

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

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

    allRepos = forAllSystems (system: let
      utils = import "${root.base}/common/utils.nix" {inherit system;};
      cImport = utils.customNixPkgsImport;
    in rec {
      pkgs-stable = cImport inputs.nixpkgs {};
      pkgs-unstable = cImport inputs.nixpkgs-unstable {};

      pkgs-nur = import inputs.nur {
        pkgs = pkgs-stable;
        nurpkgs = pkgs-unstable;
      };

      agenix = import inputs.agenix {inherit system;};

      cuda = {
        "12.2" = cImport inputs.nixpkgs-cuda-12_2 {cudaSupport = true;};
        "12.4" = cImport inputs.nixpkgs-cuda-12_4 {cudaSupport = true;};
      };
    });

    devices = [
      ./devices/KurikoG14
      ./devices/iprc
    ];
  in
    builtins.foldl' (
      acc: device: (nixpkgs.lib.recursiveUpdate acc (import device {
        inherit inputs root versionMap allRepos;
      }))
    )
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    }
    devices;
}