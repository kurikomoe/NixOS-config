{
  description = "Kuriko's C/C++ Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    fenix.url = "github:nix-community/fenix";

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
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
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
                zlib.dev
                openssl.dev
                stdenv.cc.cc.lib

                gnumake
                ninja
                cmake
                xmake
                mold
                clang-tools

                # libs

                # tools
                just
                hello

                uv
                my-python
              ]
              ++ config.pre-commit.settings.enabledPackages);

            shellHook = ''
              ${config.pre-commit.shellHook}
              test -f .venv/bin/activate \
                && source .venv/bin/activate
              test -f pyproject.toml && uv sync

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

          # C/C++
          clang-format.enable = true;

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
