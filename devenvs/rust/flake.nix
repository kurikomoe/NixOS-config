{
  description = "Kuriko's Rust Template";

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
      imports = [inputs.devenv.flakeModule];
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
          overlays = [
            inputs.fenix.overlays.default
          ];
        };

        cargoTOML = builtins.fromTOML (builtins.readFile ./Cargo.toml);
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

        rustPlatform = pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };

        runtimeLibs = with pkgs; [
          pkg-config
          openssl
        ];

        env = {
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };
      in rec {
        formatter = pkgs.alejandra;

        packages.default = rustPlatform.buildRustPackage rec {
          inherit version env;
          pname = name;
          cargoLock.lockFile = ./Cargo.lock;
          src = pkgs.lib.cleanSource ./.;

          buildInputs = with pkgs; [] ++ runtimeLibs;
          nativebuildInputs = with pkgs; [] ++ runtimeLibs;
        };

        packages.docker = pkgs.dockerTools.buildImage {
          inherit name;
          tag = version;
          config.Cmd = ["${packages.default}/bin/${name}"];
        };

        devenv.shells.default = {
          packages = with pkgs;
            [
              hello
              cargo-generate
            ]
            ++ runtimeLibs;

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

          git-hooks.hooks = {
            alejandra.enable = true;
            shellcheck.enable = true;

            clippy.enable = true;
            rustfmt.enable = true;

            # Python
            isort.enable = true;
            pyright.enable = true;
            # mypy.enable = true;
            # pylint.enable = true;
            # flake8.enable = true;

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
