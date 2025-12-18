{
  description = "Kuriko's AIO Dev Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    kuriko-nur.url = "github:kurikomoe/nur-packages";
    # kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks.flakeModule
      ];

      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        system,
        lib,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [];
          };
          overlays = [];
        };
        inherit (pkgs) mkShell lib;

        pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

        my-python-packages = pkgs.python313Packages;
        my-python = pkgs.python313.withPackages (ps:
          with ps; [
            pyyaml
            pysocks
          ]);
      in rec {
        formatter = pkgs.alejandra;

        packages.fhs = pkgs.buildFHSEnv {
          name = "fhs-devenv";

          targetPkgs = pkgs:
            with pkgs; [
              pkg-config
              stdenv.cc
              glibc
              zlib
            ];

          runScript = "fish";
        };

        devShells.default = let
          # inherit (pre-commit) shellHook enabledPackages;
        in
          mkShell rec {
            hardeningDisable = ["all"];
            packages = with pkgs; ([
                pkg-config
                zlib.dev
                openssl.dev
                stdenv.cc.cc.lib

                xmake
                cmake
                gnumake
                ninja

                hello
                just
                fish

                uv
                my-python
              ]
              ++ config.pre-commit.settings.enabledPackages);

            shellHook = ''
              ${config.pre-commit.shellHook}
              test -f .venv/bin/activate \
                && source .venv/bin/activate
              test -f pyproject.toml && uv sync

              export ROOT=$(realpath $PWD)
              # export LLVM_DIR=$ROOT/llvm-project/build
              # export PATH="$LLVM_DIR/bin:$PATH"

              # Enter FHS env
              # $\{packages.fhs}/bin/fhs-devenv
            '';

            env = rec {
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ([
                  "/usr/lib/wsl" # for wsl env
                ]
                ++ packages);
            };
          };

        pre-commit.settings.hooks = {
          alejandra.enable = true;
          shellcheck.enable = true;
          commitizen.enable = true;
          trufflehog = {
            enable = true;
            entry = builtins.toString inputs.kuriko-nur.legacyPackages.${system}.precommit-trufflehog;
            stages = ["pre-push" "pre-commit"];
          };
        };
      };
    };
}
