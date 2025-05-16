{
  description = "Kuriko's Javascript/Typescript Workspace";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";

    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    fenix.url = "github:nix-community/fenix";
    kuriko-nur.url = "github:kurikomoe/nur-packages";
  };

  nixConfig = {
    substituters = [
      https://mirrors.ustc.edu.cn/nix-channels/store
      https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
      https://nix-community.cachix.org
      https://kurikomoe.cachix.org
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

        packageManager = "pnpm";

        runtimeLibs = with pkgs; [];
      in {
        devenv.shells.default = {
          packages = with pkgs;
            [
              hello
            ]
            ++ runtimeLibs;

          languages.typescript.enable = true;
          languages.javascript = {
            enable = true;

            "${packageManager}" = {
              enable = true;
              install.enable = true;
            };
          };

          languages.python = {
            enable = false;
            package = pkgs.python312;
            uv.enable = true;
          };

          enterShell = ''
            hello
          '';

          dotenv.enable = true;

          pre-commit.hooks = {
            alejandra.enable = true;
            shellcheck.enable = true;

            # Python
            isort.enable = true;
            # mypy.enable = true;
            pylint.enable = true;
            # pyright.enable = true;
            # flake8.enable = true;

            # JS
            eslint.enable = true;
            eslint-typescript = {
              enable = true;
              name = "eslint typescript";
              entry = "${packageManager} eslint ";
              files = "\\.(tsx|ts|js)$";
              types = ["text"];
              excludes = ["dist/.*"];
              pass_filenames = true;
              verbose = true;
            };

            # Check Secrets
            trufflehog = {
              enable = true;
              entry = let
                script = pkgs.writeShellScript "precommit-trufflehog" ''
                  set -e
                  ${pkgs.trufflehog}/bin/trufflehog --no-update git "file://$(git rev-parse --show-toplevel)" --since-commit HEAD --results=verified --fail
                '';
              in
                builtins.toString script;
            };
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
