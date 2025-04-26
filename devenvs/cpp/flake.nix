{
  description = "Kuriko's C/C++ Template";

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

    kuriko-nur = {
      url = "github:kurikomoe/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

        runtimeLibs = with pkgs; [];
      in {
        formatter = pkgs.alejandra;

        devenv.shells.default = {
          # Enable this to avoid forced -O2
          # hardeningDisable = [ "all" ];

          packages = with pkgs;
            [
              # requirements
              pkg-config
              stdenv.cc.cc.lib

              cmake
              clang-tools
              ninja
              mold

              # libs

              # tools
              just
              hello
            ]
            ++ runtimeLibs;

          env = {
            LD_LIBRARY_PATH = lib.makeLibraryPath runtimeLibs;
          };

          enterShell = ''
            hello
          '';

          languages.c = {
            enable = true;
            debugger = pkgs.gdb;
          };

          languages.cplusplus.enable = true;

          languages.python = {
            enable = false;
            package = pkgs.python312;
            # version = "3.12";
            uv.enable = true;
          };

          pre-commit.hooks = {
            alejandra.enable = true;
            # C/C++
            clang-format.enable = true;
            # Python
            isort.enable = true;
            mypy.enable = true;
            pylint.enable = true;
            pyright.enable = true;
            flake8.enable = true;

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
    };
}
