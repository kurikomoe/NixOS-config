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

        dotnetVersion = "net9.0";

        dotnetPkgs = with pkgs;
        with dotnetCorePackages;
          combinePackages [
            sdk_9_0
            # sdk_8_0_3xx
            # sdk_7_0_3xx
            # sdk_6_0_1xx
          ];

        name = "helloworld";
      in {
        formatter = pkgs.alejandra;

        packages.default = pkgs.stdenv.mkDerivation rec {
          inherit name;
          pname = name;
          version = "1.0";
          src = lib.cleanSource ./.;

          env = {
            DOTNET_ROOT = "${dotnetPkgs}/share/dotnet";
            LD_LIBRARY_PATH = "${lib.makeLibraryPath [pkgs.icu]}";
          };

          # build time deps
          buildInputs = with pkgs; [
            dotnetPkgs
            clang
            zlib
            icu
          ];

          # on build machine
          nativeBuildInputs = with pkgs; [
            icu
          ];

          # packed into appimage
          propagatedBuildInputs = with pkgs; [
            dotnetPkgs
            bash
            icu
          ];

          buildPhase = ''
            mkdir -p $out/bin
            dotnet build -c Release
          '';

          installPhase = ''
            install -Dm755 bin/Release/${dotnetVersion}/${name}* $out/bin/
            install -Dm755 bin/Release/${dotnetVersion}/*.dll $out/bin/

            # build a caller
            cat > "$out/bin/${name}" << EOF
            #! ${pkgs.bash}/bin/bash
            export DOTNET_ROOT=${dotnetPkgs}
            exec $out/bin/${name}
            EOF

            chmod 755 "$out/bin/${name}"
            echo "$out/bin/${name}"
          '';

          postFixup = ''
          '';

          meta = {
            mainProgram = name;
          };
        };

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

          env = {
            DOTNET_ROOT = "${dotnetPkgs}/share/dotnet";
          };

          languages.dotnet = {
            enable = true;
            package = dotnetPkgs;
          };

          languages.python = {
            enable = false;
            # package = pkgs.python312;
            # version = "3.12";
            uv.enable = false;
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
            # pylint.enable = true;
            # pyright.enable = true;
            flake8.enable = true;
            # autoflake.enable = true;

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
