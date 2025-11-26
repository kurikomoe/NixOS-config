{
  description = "Kuriko's C/C++ Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    kuriko-nur.url = "github:kurikomoe/nur-packages";
    kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://kurikomoe.cachix.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "kurikomoe.cachix.org-1:NewppX3NeGxT8OwdwABq+Av7gjOum55dTAG9oG7YeEI="
    ];
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks.flakeModule
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
          config.permittedInsecurePackages = [
            "dotnet-sdk-7.0.317"
            "dotnet-sdk-6.0.136"
          ];
          overlays = [];
        };

        inherit (pkgs) mkShell lib;

        pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

        my-python-packages = pkgs.python313Packages;
        my-python = pkgs.python313.withPackages (ps:
          with ps; [
            pyyaml
            pysocks
            venvShellHook
          ]);

        dotnetPkgs = with pkgs;
        with dotnetCorePackages;
          combinePackages [
            sdk_10_0-bin
            sdk_9_0-bin
            # sdk_8_0-bin
            # sdk_7_0_3xx-bin
            # sdk_6_0_1xx-bin
          ];
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = let
          # inherit (pre-commit) shellHook enabledPackages;
        in
          mkShell rec {
            hardeningDisable = ["all"];
            packages = with pkgs; ([
                # requirements
                pkg-config
                stdenv.cc.cc.lib
                icu.dev
                zlib.dev
                openssl.dev

                gnumake
                ninja
                cmake
                clang

                # tools
                just
                hello

                dotnetPkgs
                pkgs-kuriko-nur.dotnet-script

                uv
                my-python
                my-python-packages.venvShellHook
              ]
              ++ config.pre-commit.settings.enabledPackages);

            shellHook = ''
              ${config.pre-commit.shellHook}
              test -f .venv/bin/activate \
                && source .venv/bin/activate \
                || echo "Please use `uv venv` to init first"
              test -f pyproject.toml && uv sync

              export GO111MODULE=on
              export GOPROXY=https://goproxy.cn,direct

              hello
            '';

            env = rec {
              LD_LIBRARY_PATH = lib.makeLibraryPath ([
                  "/usr/lib/wsl" # for wsl env
                ]
                ++ packages);
            };
          };

        pre-commit.settings.hooks = {
          alejandra.enable = true;
          shellcheck.enable = true;

          # Python
          isort.enable = true;
          pyright.enable = true;
          flake8.enable = true;
          # mypy.enable = true;

          # Check Secrets
          trufflehog = {
            enable = true;
            entry = builtins.toString inputs.kuriko-nur.legacyPackages.${system}.precommit-trufflehog;
            stages = ["pre-push" "pre-commit"];
          };
        };
      };
    };
}
