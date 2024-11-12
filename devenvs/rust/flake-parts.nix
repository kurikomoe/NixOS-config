{
  description = "My Python DevEnv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-root.url = "github:srid/flake-root";

    mission-control.url = "github:Platonic-Systems/mission-control";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {};

      imports = [
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        inputs.process-compose-flake.flakeModule
      ];

      systems = ["x86_64-linux"];

      perSystem = {
        config,
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.fenix.overlays.default
          ];
        };
        lib = pkgs.lib;

        pkgs-static = pkgs.pkgsStatic;

        RUST_TARGET = "x86_64-unknown-linux-musl";

        toolchain = with pkgs.fenix;
          combine [
            stable.rustc
            stable.cargo
            pkgs.fenix.targets.${RUST_TARGET}.stable.rust-std
            pkgs.fenix.targets."x86_64-unknown-linux-gnu".stable.rust-std
          ];
      in {
        packages = rec {
          release = pkgs-static.rustPlatform.buildRustPackage rec {
            name = "hello-sea-orm";
            version = "0.1.0";
            src = ./.;

            env = {
              inherit RUST_TARGET;
              PKG_CONFIG_PATH = "${pkgs-static.openssl.dev}/lib/pkgconfig";
            };

            nativeBuildInputs = with pkgs-static; [
              openssl
              pkg-config
              toolchain
              musl
            ];

            cargoLock.lockFile = ./Cargo.lock;
          };

          default = release.overrideAttrs (oldAtts: {
            doCheck = false;
            buildType = "debug";
          });
        };

        devShells.default = pkgs-static.mkShell {
          inputsFrom = [config.mission-control.devShell];

          inherit RUST_TARGET;

          CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${RUST_TARGET}-gcc";

          shellHook = ''
          '';

          buildInputs = [
          ];

          packages = with pkgs-static;
            [
              openssl
              pkg-config
              musl
              toolchain
            ]
            ++ (with pkgs; [
              # cargo-zigbuild
            ]);
        };

        mission-control.scripts = {
          build.exec = "cargo build --target=${RUST_TARGET};";
          run.exec = "cargo run --target=${RUST_TARGET}";
        };

        process-compose.default = {
          imports = [
            inputs.services-flake.processComposeModules.default
          ];

          processes = {
            ponysay.command = ''
              while true; do
                ${lib.getExe pkgs.ponysay} "Enjoy our sqlite-web demo!"
                sleep 2
              done
            '';
          };
        };
      };
    };
}
