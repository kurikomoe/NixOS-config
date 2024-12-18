{
  description = "Kuriko's AIO Dev Template";

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

    fenix.url = "github:nix-community/fenix";
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
        lib,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              # "dotnet-sdk-7.0.410"
            ];
          };
          overlays = [];
        };
      in rec {
        formatter = pkgs.alejandra;

        devenv.shells.base = {
          packages = with pkgs; [];

          languages.python = {
            enable = true;
            uv.enable = true;
            # package = pkgs.python312;
            # version = "3.12";
            # poetry = {
            #   enable = false;
            #   activate.enable = true;
            # };
          };

          pre-commit = {
            addGcRoot = true;
            hooks = {
              alejandra.enable = true;
              # Python
              isort.enable = true;
              mypy.enable = true;
              pylint.enable = true;
              pyright.enable = true;
              flake8.enable = true;
              autoflake.enable = true;
            };
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };

        devenv.shells = rec {
          # ====================== Python ==========================
          python =
            lib.recursiveUpdate devenv.shells.base
            rec {
              packages = with pkgs; [
                hello
              ];

              enterShell = ''
                hello
              '';

              languages.python = {
                enable = true;
                uv.enable = true;
                # package = pkgs.python312;
                # version = "3.12";
                # poetry = {
                #   enable = true;
                #   activate.enable = true;
                # };
              };
            };

          # ====================== JavaScript ==========================
          js =
            lib.recursiveUpdate devenv.shells.base
            {
              packages = with pkgs; [
                hello
              ];

              languages.javascript = {
                enable = true;

                # Select one and comment out
                # bun = {
                #   enable = true;
                # };
                # pnpm = {
                #   enable = true;
                #   install.enable = true;
                # };
                # yarn = {
                #   enable = true;
                #   install.enable = true;
                # };
              };

              enterShell = ''
                hello
              '';

              pre-commit.hooks = {
                eslint.enable = true;
              };
            };

          # ====================== C/C++ ==========================
          cpp =
            lib.recursiveUpdate devenv.shells.base
            rec {
              # Enable this to avoid forced -O2
              # hardeningDisable = [ "all" ];

              # Some useful stdenvs
              # stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.stdenv;
              # stdenv = pkgs.llvmPackages_16.stdenv;

              packages = with pkgs; [
                pkg-config
                stdenv.cc.cc.lib

                # Build Tools
                cmake
                clang-tools
                autoreconfHook
                ninja
                mold

                # libs

                # tools
                just
                hello
              ];

              enterShell = ''
                hello
              '';

              languages.cplusplus.enable = true;
              languages.c = {
                enable = true;
                debugger = pkgs.gdb;
              };

              pre-commit.hooks = {
                clang-format.enable = true;
              };
            };

          # ====================== Rust ==========================
          rust = let
            rust_channel = "stable";
            rust_target = "x86_64-unknown-linux-gnu";
            toolchains = with pkgs;
              fenix.combine [
                fenix.${rust_channel}.rustc
                fenix.${rust_channel}.cargo
                fenix.${rust_channel}.clippy
                fenix.${rust_channel}.rust-analyzer
                fenix.${rust_channel}.rust-src
                # fenix.target.${rust_target}.${rust_channel}.rust-std
              ];
          in
            lib.recursiveUpdate devenv.shells.base
            rec {
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

              scripts.build.exec = "cargo build $@";
              scripts.run.exec = "cargo run $@";

              pre-commit.hooks = {
                clippy.enable = true;
                rust-fmt = {
                  enable = true;
                };
              };
            };

          # ====================== dotnet ==========================
          dotnet = let
            # For EOL dotnet, should add to allowInsecure in pkgs import.
            combinedDotnetPkgs = with pkgs;
            with dotnetCorePackages;
              combinePackages [
                sdk_9_0
                # sdk_8_0_3xx
                # sdk_7_0_4xx
                # sdk_6_0_1xx
              ];
          in
            lib.recursiveUpdate devenv.shells.base
            rec {
              packages = with pkgs; [
                hello
              ];

              enterShell = ''
                hello
              '';

              languages.dotnet = {
                enable = true;
                package = combinedDotnetPkgs;
              };

              pre-commit.hooks = {
                dotnet = {
                  enable = true;
                  name = "dotnet format";
                  entry = "dotnet format";
                  files = "\\.cs$";
                  language = "dotnet";
                  pass_filenames = false;
                  stages = ["pre-commit"];
                };
              };
            };
        };
      };
    };
}
