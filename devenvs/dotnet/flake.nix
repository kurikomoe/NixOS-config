{
  description = "Kuriko's dotnet Template";

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
          config.allowUnfree = true;
          overlays = [];
        };

        dotnet-pkgs = with pkgs;
        with dotnetCorePackages;
          combinePackages [
            sdk_9_0
            # sdk_8_0_3xx
            # sdk_7_0_3xx
            # sdk_6_0_1xx
          ];
      in {
        formatter = pkgs.alejandra;

        devenv.shells.default = {
          packages = with pkgs; [
            # requirements
            pkg-config
            zlib
            clang

            # tools
            just
            hello
          ];

          languages = {
            languages.dotnet = {
              enable = true;
              package = dotnet-pkgs;
            };

            python = {
              enable = false;
              # package = pkgs.python312;
              # version = "3.12";
              poetry = {
                enable = false;
                activate.enable = true;
              };
            };
          };

          scripts.pack.exec = ''
            nix bundle --bundler github:ralismark/nix-appimage  .#helloworld --option sandbox false
          '';

          pre-commit.hooks = {
            alejandra.enable = true;
            clang-format.enable = true;

            # Python
            isort.enable = true;
            mypy.enable = true;
            pylint.enable = true;
            pyright.enable = true;
            flake8.enable = true;
            autoflake.enable = true;
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };
    };
}
