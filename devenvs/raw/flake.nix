{
  description = "Kuriko's AIO Dev Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";

    kuriko-nur.url = "github:kurikomoe/nur-packages";
    kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
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

        pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

        my-python = pkgs.python312.withPackages (ps:
          with ps; [
            pyyaml
          ]);
      in rec {
        formatter = pkgs.alejandra;

        pre-commit.settings.hooks = {
          alejandra.enable = true;
          shellcheck.enable = true;
          trufflehog = {
            enable = true;
            entry = builtins.toString inputs.kuriko-nur.legacyPackages.${system}.precommit-trufflehog;
            stages = ["pre-push" "pre-commit"];
          };
        };

        packages.fhs = pkgs.buildFHSEnv {
          name = "fhs-devenv";

          targetPkgs = pkgs:
            with pkgs; [
              pkg-config
              llvmPackages_16.stdenv.cc
              stdenv.cc
              glibc
              zlib
            ];

          runScript = "fish";
        };

        devShells.default = pkgs.mkShell {
          hardeningDisable = ["all"];

          packages = with pkgs; [
            cmake
            hello
            just
            my-python
            ninja
            fish
          ];

          shellHook = ''
            ${config.pre-commit.installationScript}

            export ROOT=$(realpath $PWD)
            export LLVM_DIR=$ROOT/llvm-project/build

            # export PATH="$LLVM_DIR/bin:$PATH"

            # Enter FHS env
            ${packages.fhs}/bin/fhs-devenv
          '';
        };
      };
    };
}
