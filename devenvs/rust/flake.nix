{
  description = "Kuriko's Rust Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix";
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
        pkgs = import inputs.nixpkgs-nixos {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.fenix.overlays.default
          ];
        };

        rust_channel = "stable";
        rust_target = "x86_64-unknown-linux-gnu";
        toolchains = with pkgs; fenix.combine [
          fenix.${rust_channel}.rustc
          fenix.${rust_channel}.cargo
          fenix.${rust_channel}.clippy
          fenix.${rust_channel}.rust-analyzer
          fenix.${rust_channel}.rust-src
          # fenix.target.${rust_target}.${rust_channel}.rust-std
        ];

      in {
        devenv.shells.default = {
          packages = with pkgs; [
            toolchains
            cargo-generate
            hello
          ];

          enterShell = ''
            hello
          '';

          processes.hello.exec = "hello";

          scripts.build.exec = "cargo build $@";

          pre-commit.hooks = { };
          cachix.push = "kurikomoe";
        };

      };

      flake = { };
    };
}
