{
  description = "Kuriko's Golang Template";

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
        ...
      }: let
        name = "test";

        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };
      in {
        imports = [
          # ./build.nix
        ];

        packages.default = packages."sakura-share";

        packages.${name} = pkgs.buildGoModule {
          pname = name;
          version = "0.0.1";

          GOPROXY = "https://goproxy.cn,direct";
          GO111MODULE = "on";

          src = lib.cleanSource ./.;

          vendorHash = "";
        };

        devenv.shells.default = {
          packages = with pkgs; [
            hello
          ];

          enterShell = ''
            export GO111MODULE=on
            export GOPROXY=https://goproxy.cn,direct

            hello
          '';

          languages.go = {
            enable = true;
            package = pkgs.go;
          };

          processes.hello.exec = "hello";

          pre-commit.hooks = {
            alejandra.enable = true;
            gofmt.enable = true;

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
