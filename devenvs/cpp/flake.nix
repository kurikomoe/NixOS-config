{
  description = "Kuriko's Default Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-devenv.url = "github:cachix/devenv-nixpkgs/rolling";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs-devenv";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', system, ... }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ ];
        };

      in {
        devenv.shells.default = {
          packages = with pkgs; [
            # requirements
            pkg-config
            stdenv.cc.cc.lib

            cmake
            autoreconfHook
            ninja

            # intel-isal
            nasm

            # baseline test
            rocksdb
            redis

            # tools
            just
            hello
          ];

          enterShell = ''
            # disable `as` to let intel-isal fallback to nasm
            export AS=""
            export HAVE_NASM='yes'
          '';

          pre-commit.hooks = { };
          cachix.push = "kurikomoe";
        };

      };

      flake = { };
    };
}
