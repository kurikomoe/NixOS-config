{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-nixos.url = "github:nixos/nixpkgs/master";

    systems.url = "github:nix-systems/default";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    nixpkgs-python.inputs = {nixpkgs.follows = "nixpkgs";};
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
    });

    devShells = forEachSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            # cudaSupport = true;
            # cudnnSupport = true;
          };
        };

        pkgs-nixos = import inputs.nixpkgs-nixos {
          inherit system;
          config = {
            allowUnfree = true;
            # cudaSupport = true;
            # cudnnSupport = true;
          };
        };
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              # https://devenv.sh/reference/options/
              packages = with pkgs; [
                hello
              ];

              enterShell = ''
                export BLUEARCHIVE=true;
                export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib/"
              '';

              languages.python = {
                enable = true;
                package = pkgs.python3;
                poetry = {
                  enable = true;
                  activate.enable = true;
                  install.enable = true;
                };
              };
            }
          ];
        };
      }
    );
  };
}
