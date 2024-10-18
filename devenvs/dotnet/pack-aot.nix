# packing dotnet aot executable as appimage
# just use devdev and `pack` command
# the key point is to modify the rpath so that dotnet dlopen can find libicu
{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, flake-parts, ... } @ inputs:

  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.devenv.flakeModule
    ];

    systems = nixpkgs.lib.systems.flakeExposed;

    perSystem = {config, self', inputs', pkgs, system, ... }:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      dotnet_runtime = pkgs.dotnetCorePackages.dotnet_9.runtime;
      dotnet_sdk = pkgs.dotnetCorePackages.dotnet_9.sdk;

      name = "helloworld";
    in {
      packages = {
        devenv-up = self.devShells.${system}.default.config.procfileScript;

        default = pkgs.stdenv.mkDerivation rec {
          inherit name;
          pname = name;

          version = "1.0";

          src = ./.;

          # essential for build time
          env = {
            DOTNET_ROOT="${dotnet_sdk}";
            LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.icu ]}";
          };

          # on build machine
          nativeBuildInputs = with pkgs; [ ];

          # packed into appimage
          propagatedBuildInputs = with pkgs; [
            icu
          ];

          # build time deps
          buildInputs = with pkgs; [
            dotnet_sdk
            clang
            zlib
            icu
          ];

          buildPhase = ''
            mkdir -p $out/bin/dotnet
            dotnet publish -c Release
          '';

          installPhase = ''
            install -Dm755 bin/Release/net9.0/linux-x64/publish/* $out/bin
          '';

          postFixup = ''
            patchelf \
              --set-rpath ${lib.makeLibraryPath propagatedBuildInputs} \
              $out/bin/${name}
          '';

          meta = {
            mainProgram = name;
          };
        };
      };

      devShells.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            # https://devenv.sh/reference/options/
            packages = with pkgs; [
              hello
              clang
              zlib
            ];

            languages.dotnet = {
              enable = true;
              package = dotnet_sdk;
            };

            enterShell = ''
              hello
            '';

            processes.hello.exec = "hello";

            scripts.pack.exec = ''
              echo sandbox is disabled for nupkg to update;
              nix bundle --bundler github:ralismark/nix-appimage --option sandbox false;
            '';
          }
        ];
      };
    };
  };
}
