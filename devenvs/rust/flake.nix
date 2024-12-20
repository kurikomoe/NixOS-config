{
  description = "Kuriko's Rust Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix";

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
          overlays = [
            inputs.fenix.overlays.default
          ];
        };

        rust_channel = "stable";
        rust_target = "x86_64-unknown-linux-gnu";
        # toolchains = with pkgs;
        #   fenix.combine [
        #     fenix.${rust_channel}.rustc
        #     fenix.${rust_channel}.cargo
        #     fenix.${rust_channel}.clippy
        #     fenix.${rust_channel}.rust-analyzer
        #     fenix.${rust_channel}.rust-src
        #     # fenix.target.${rust_target}.${rust_channel}.rust-std
        #   ];
      in {
        devenv.shells.default = {
          packages = with pkgs; [
            hello
            cargo-generate
          ];

          enterShell = ''
            hello
          '';

          languages.rust = {
            enable = true;
            channel = rust_channel;
            components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
            mold.enable = true;
            targets = [];
          };

          languages.python = {
            enable = true;
            # package = pkgs.python311;
            # version = "3.11";
            poetry = {
              enable = false;
              activate.enable = true;
            };
          };

          processes.hello.exec = "hello";

          scripts.build.exec = "cargo build $@";

          pre-commit = {
            addGcRoot = true;
            hooks = {
              alejandra.enable = true;
              clippy.enable = true;
              rust-fmt = {
                enable = true;
              };
            };
          };

          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
