{
  description = "Kuriko's Rust Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

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
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.fenix.overlays.default
          ];
        };

        rust_channel = "latest";
        rust_target = "x86_64-unknown-linux-gnu";

        toolchain = with pkgs;
          fenix.${rust_channel}.withComponents [
            "cargo"
            "clippy"
            "rust-src"
            "rustc"
            "rustfmt"
          ];

        rustPlatform = pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };
      in {
        packages.default = rustPlatform.buildRustPackage rec {
          pname = "hello-world";
          version = "0.0.1";
          cargoLock.lockFile = ./Cargo.lock;
          src = pkgs.lib.cleanSource ./.;
        };

        packages.docker = pkgs.dockerTools.buildImage {
          name = "hello-world";
          config = {
            Cmd = [
              "${packages.default}/bin/hello-world"
            ];
          };
        };

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
            mold.enable = false;
            toolchain.cargo = toolchain;
            toolchain.clippy = toolchain;
            toolchain.rust-analyzer = toolchain;
            toolchain.rustc = toolchain;
            toolchain.rustfmt = toolchain;
          };

          languages.python = {
            enable = true;
            uv.enable = true;
          };

          scripts."build".exec = "cargo build $@";
          scripts."run".exec = "cargo run $@";

          pre-commit = {
            addGcRoot = true;
            hooks = {
              alejandra.enable = true;
              clippy.enable = true;
              rustfmt.enable = true;
            };
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
