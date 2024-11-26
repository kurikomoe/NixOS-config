{
  description = "Kuriko's C/C++ Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
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
      in {
        formatter = pkgs.alejandra;

        devenv.shells.default = {
          packages = with pkgs; [
            # requirements
            pkg-config
            stdenv.cc.cc.lib

            cmake
            clang-tools
            autoreconfHook
            ninja
            mold

            # libs

            # tools
            just
            hello
          ];

          languages.c = {
            enable = true;
            debugger = pkgs.gdb;
          };

          languages.cplusplus.enable = true;

          languages.python = {
            enable = false;
            # package = pkgs.python312;
            poetry = {
              enable = true;
              activate.enable = true;
            };
          };

          pre-commit.hooks = {
            alejandra.enable = true;
            clang-format.enable = true;
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };
    };
}
