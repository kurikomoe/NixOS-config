{
  description = "Kuriko's dotnet Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    devenv.url = "github:cachix/devenv/latest";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    fenix.url = "github:nix-community/fenix";

    kuriko-nur.url = "github:kurikomoe/nur-packages";
    kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://kurikomoe.cachix.org"
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
        pkgs-nur-kuriko = inputs.kuriko-nur.packages.${system};

        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };

        dotnetVersion = "net9.0";

        dotnetPkgs = with pkgs;
        with dotnetCorePackages;
          combinePackages [
            dotnet-sdk_10
            # sdk_9_0
            # sdk_8_0_3xx
            # sdk_7_0_3xx
            # sdk_6_0_1xx
          ];

        runtimeLibs = with pkgs; [
          icu
          zlib
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
            LD_LIBRARY_PATH = lib.makeLibraryPath runtimeLibs;
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
          packages = with pkgs;
            [
              # requirements
              pkg-config
              zlib
              icu

              clang

              dotnetPkgs

              pkgs-nur-kuriko.dotnet-script

              # tools
              just
              hello
            ]
            ++ runtimeLibs;

          env = {
            # DOTNET_ROOT = "${dotnetPkgs}/share/dotnet";
            # LD_LIBRARY_PATH = lib.makeLibraryPath runtimeLibs;
          };

          languages.dotnet = {
            enable = true;
            package = dotnetPkgs;
          };

          languages.python = {
            enable = false;
            # package = pkgs.python312;
            # version = "3.12";
            uv.enable = true;
          };

          scripts.pack.exec = ''
            nix bundle --bundler github:ralismark/nix-appimage  .#${name} --option sandbox false
          '';

          scripts.push.exec = ''
            nix build .#devShells.x86_64-linux.default --impure
            nix-store -qR $(nix path-info .#devShells.x86_64-linux.default --impure) | cachix push kurikomoe
            rm result
          '';

          pre-commit.hooks = {
            alejandra.enable = true;
            shellcheck.enable = true;

            # Python
            # isort.enable = true;
            # mypy.enable = true;
            # pylint.enable = true;
            # pyright.enable = true;
            # flake8.enable = true;
            # autoflake.enable = true;

            # Check Secrets
            trufflehog = {
              enable = true;
              entry = builtins.toString inputs.kuriko-nur.packages.${system}.precommit-trufflehog;
              stages = ["pre-push" "pre-commit"];
            };
          };

          cachix.pull = ["devenv"];
          cachix.push = "kurikomoe";
        };
      };
    };
}
