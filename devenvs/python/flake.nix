{
  description = "Kuriko's Python Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

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
            # poetry
          ];

          enterShell = ''
            hello
          '';

          languages.python = {
            enable = true;
            package = pkgs.python312;
            # version = "3.12";

            uv.enable = true;
            uv.package = pkgs.uv;

            # poetry = {
            #   enable = true;
            #   activate.enable = true;
            # };
          };

          pre-commit.hooks = {
            alejandra.enable = true;

            # pylint.enable = true;
            # pyright.enable = true;
            flake8.enable = true;

            isort.enable = true;
            # autoflake.enable = true;
            # mypy = {
            #   enable = true;
            #   excludes = [
            #     # ".*yarn_spinner_pb2.py$"
            #     # "yarn_spinner_pb2.py"
            #     # "third/.*"
            #   ];
            #   args = [
            #     # "--disable-error-code=attr-defined"
            #   ];
            #   extraPackages = with pkgs; [
            #     # python312Packages.protobuf
            #     # python312Packages.types-protobuf
            #   ];
            # };

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
