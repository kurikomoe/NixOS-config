{
  description = "Kuriko's Tauri Template";

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
    substituters = [
      https://mirrors.ustc.edu.cn/nix-channels/store
      https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
      https://nix-community.cachix.org
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

        cargoTOML = builtins.fromTOML (builtins.readFile ./src-tauri/Cargo.toml);
        name = cargoTOML.package.name;
        version = cargoTOML.package.version;

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

        rustPlatform = pkgs-unstable.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };

        deps = with pkgs; [
          pkg-config
          openssl
        ];

        env = {
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };
      in rec {
        devenv.shells.default = {
          packages = with pkgs;
            [
              hello
              cargo-generate

              gobject-introspection
              at-spi2-atk
              atkmm
              cairo
              gdk-pixbuf
              glib
              gtk3
              harfbuzz
              librsvg
              libsoup_3
              pango
              webkitgtk_4_1
              openssl
            ]
            ++ deps;

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

          languages.javascript = {
            enable = true;
            pnpm.enable = true;
          };

          scripts."build".exec = "cargo build $@";
          scripts."run".exec = "cargo run $@";

          env = {
            CARGO_MANIFEST_DIR = "./src-tauri/";
          };

          pre-commit = {
            addGcRoot = true;
            hooks = {
              alejandra.enable = true;

              clippy.enable = true;
              clippy.settings.extraArgs = "--manifest-path ./src-tauri/Cargo.toml --no-deps";
              clippy.settings.offline = false;

              rustfmt.enable = true;
              rustfmt.settings.manifest-path = "./src-tauri/Cargo.toml";

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
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };

      flake = {};
    };
}
