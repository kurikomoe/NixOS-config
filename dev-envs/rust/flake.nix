{
  description = "Kuriko Rust Devenv";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

  };

  outputs = { self, flake-parts, fenix, nixpkgs }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [

      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inputs'.nixpkgs.overlays = [ fenix.overlays.default ];

          toolchain = inputs'.fenix.complete;

        in {
          # Build Rust Packages
          packages.default = (pkgs.makeRustPlatform {
            inherit (toolchain) cargo rustc;
          }).buildRustPackage {
            pname = "auto-novel-mirror";
            version = "0.1.0";
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
          };


          # DevShell
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              hello
            ];

            shellHook = ''
              hello
            '';
          };

        };

      flake = {


      };
    };
}
