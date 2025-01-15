{
  description = "Kuriko's AIO Dev Template";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

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

  outputs = inputs @ {
    flake-parts,
    devenv-root,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

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

        pkgs-unstable = import inputs.nixpkgs-unstable {
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

        packages.default = pkgs.hello;

        devenv.shells.base = {
          name = "base";

          devenv.root = let
            devenvRootFileContent = builtins.readFile devenv-root.outPath;
          in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          packages = with pkgs; [config.packages.default];

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
              pylint.enable = true;
              pyright.enable = true;
              flake8.enable = true;

              isort.enable = true;
              autoflake.enable = true;
              mypy = {
                enable = true;
                excludes = [
                  # ".*yarn_spinner_pb2.py$"
                  # "yarn_spinner_pb2.py"
                  # "third/.*"
                ];
                args = [
                  # "--disable-error-code=attr-defined"
                ];
                extraPackages = with pkgs; [
                  # python312Packages.protobuf
                  # python312Packages.types-protobuf
                ];
              };

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

              languages.typescript.enable = true;
              languages.javascript = {
                enable = true;

                ## Select one and comment out others
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
                inherit toolchain;

                enable = true;
                mold.enable = true;
                targets = [];
              };

              scripts.build.exec = "cargo build $@";
              scripts.run.exec = "cargo run $@";

              pre-commit.hooks = {
                clippy.enable = true;
                rustfmt = {
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

          ## ====================== case by case projects ==========================

          # ====================== dixous desktop linux ==========================
          dixous = let
            rust_channel = "nightly";
            rust_target = "x86_64-unknown-linux-gnu";
          in
            lib.recursiveUpdate devenvs.shells.rust
            rec {
              packages = with pkgs; [
                cargo-binstall

                # Desktop
                glib
                libsoup_3
                webkitgtk_4_1
                xdo
                xdotool # -lxdo
              ];

              languages.rust = {
                enable = true;
                mold.enable = false;
                toolchain.cargo = toolchain;
                toolchain.clippy = toolchain;
                toolchain.rust-analyzer = toolchain;
                toolchain.rustc = toolchain;
                toolchain.rustfmt = toolchain;
              };
            };
        };
      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
