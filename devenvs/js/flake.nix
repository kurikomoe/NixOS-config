{
  description = "Kuriko's JS Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs = {nixpkgs.follows = "nixpkgs";};
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
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };
      in {
        devenv.shells.default = {
          packages = with pkgs; [
            hello
          ];

          languages.javascript = {
            enable = true;

            # select one
            bun = {
              enable = true;
              install.enable = true;
            };
            pnpm = {
              enable = false;
              install.enable = true;
            };
            yarn = {
              enable = false;
              install.enable = true;
            };
          };

          languages.python = {
            enable = false;
            # package = pkgs.python312;
            poetry = {
              enable = true;
              activate.enable = true;
            };
          };

          enterShell = ''
            hello
          '';

          pre-commit = {
            addGcRoot = true;
            hooks = {
              alejandra.enable = true;
              # JS
              eslint.enable = true;
              # Python
              isort.enable = true;
              mypy.enable = true;
              pylint.enable = true;
              pyright.enable = true;
              flake8.enable = true;
            };
          };

          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
