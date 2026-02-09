{
  description = "Kuriko's JavaScript/Typescript Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    kuriko-main.url = "github:kurikomoe/NixOS-config/main?dir=devenvs";
    kuriko-nur.url = "github:kurikomoe/nur-packages";
    kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://kurikomoe.cachix.org"
      "https://nix-cache.0v0.io/r2"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "kurikomoe.cachix.org-1:NewppX3NeGxT8OwdwABq+Av7gjOum55dTAG9oG7YeEI="
      "r2:p04JD2QTSWn937oqqCMX9CdMAd71ulb1FZZm+3Nd/9c="
    ];
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks.flakeModule
        inputs.kuriko-main.flakeModules.devShellBase
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        system,
        lib,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              nodejs = prev.nodejs_22;
            })
          ];
        };
        inherit (pkgs) lib;
        pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

        electronLibs = with pkgs; [
          alsa-lib
          at-spi2-atk
          cairo
          cups
          dbus
          expat
          gdk-pixbuf
          glib
          gtk3
          gtk4
          nss
          nspr
          libx11
          libxcb
          libxcomposite
          libxdamage
          libxext
          libxfixes
          libxrandr
          libxkbfile
          pango
          pciutils
          stdenv.cc.cc
          systemd
          libnotify
          pipewire
          libsecret
          libpulseaudio
          speechd-minimal
          libdrm
          libgbm
          libxkbcommon
          libxshmfence
          libGL
          vulkan-loader
        ];
      in rec {
        formatter = pkgs.alejandra;

        packages.fhsEnv = pkgs.buildFHSEnv {
          name = "electron-fhs-env";
          targetPkgs = pkgs:
            (with pkgs; [
              electron-bin
              fish
            ])
            ++ electronLibs;
          runScript = "bash -c 'export FHS=1; exec fish'";
        };

        devShells.fhs = packages.fhsEnv.env;

        devShellBase = let
        in {
          packages =
            (with pkgs; [
              nodejs
              nodePackages.pnpm
              typescript
              eslint
              prettier
            ])
            ++ electronLibs;

          shellHook = ''
            hello
          '';

          env = rec {};
        };
        pre-commit.settings.hooks = {
          eslint.enable = true;
          eslint-typescript = {
            enable = true;
            name = "eslint typescript";
            entry = "pnpm eslint ";
            files = "\\.(tsx|ts|js)$";
            types = ["text"];
            excludes = ["dist/.*"];
            pass_filenames = true;
            verbose = true;
          };
        };
      };
    };
}
