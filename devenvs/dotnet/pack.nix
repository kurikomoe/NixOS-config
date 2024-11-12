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

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;

      helloworld = let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
        pkgs.stdenv.mkDerivation rec {
          pname = "helloworld";
          version = "1.0";

          src = ./.;

          # essential for build time
          env = {
            DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_9_0}";
            LD_LIBRARY_PATH = "${lib.makeLibraryPath [pkgs.icu]}";
          };

          # on build machine
          nativeBuildInputs = with pkgs; [];

          # packed into appimage
          propagatedBuildInputs = with pkgs; [
            icu
          ];

          # build time deps
          buildInputs = with pkgs; [
            dotnetCorePackages.sdk_9_0
            clang
            zlib
            icu
          ];

          buildPhase = ''
            mkdir -p $out/bin
            dotnet publish -c Release
          '';

          installPhase = ''
            install -Dm755 bin/Release/net9.0/linux-x64/publish/* $out/bin
          '';

          postFixup = ''
            patchelf \
              --set-rpath ${lib.makeLibraryPath propagatedBuildInputs} \
              $out/bin/helloworld
          '';

          meta = {
            mainProgram = "helloworld";
          };
        };
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
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
                package = pkgs.dotnetCorePackages.sdk_9_0;
              };

              enterShell = ''
                hello
              '';

              processes.hello.exec = "hello";

              scripts.pack.exec = ''
                nix bundle --bundler github:ralismark/nix-appimage  .#helloworld --option sandbox false
              '';
            }
          ];
        };
      });
  };
}
