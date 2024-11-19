{
  description = "Kuriko's Default Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    devenv = {
      url = "github:cachix/devenv/1.3.1";
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
            bun.enable = true;
          };

          languages.python = {
            enable = true;
            poetry.enable = true;
          };

          enterShell = ''
            hello
          '';

          processes.hello.exec = "hello";

          pre-commit.hooks = {};
          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
