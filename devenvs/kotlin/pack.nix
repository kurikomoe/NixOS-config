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
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        lib = pkgs.lib;

        kotlin-native-fix = pkgs.kotlin-native.overrideAttrs (oldAttrs: rec {
          buildInputs = with pkgs; [
            bubblewrap
          ];

          startScript = pkgs.writeShellScript "kotlinc-native-fix" ''
            blacklist=(/nix /dev /usr /lib /lib64 /proc)

            declare -a auto_mounts
            # loop through all directories in the root
            for dir in /*; do
              # if it is a directory and it is not in the blacklist
              if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
                # add it to the mount list
                auto_mounts+=(--bind "$dir" "$dir")
              fi
            done

            # Bubblewrap 启动脚本
            cmd=(
              ${pkgs.bubblewrap}/bin/bwrap
              --chdir "$(pwd)"
              --die-with-parent
              --dev-bind /dev /dev
              --ro-bind /nix /nix
              --proc /proc
              --bind /usr/bin/env /usr/bin/env
              --bind ${pkgs.glibc}/lib /lib
              --bind ${pkgs.glibc}/lib /lib64
              --bind /tmp/kotlin-native-cache ${pkgs.kotlin-native}/klib/cache
              "''${auto_mounts[@]}"

              ${pkgs.kotlin-native}/bin/kotlinc-native "$@"
            )
            exec "''${cmd[@]}"
          '';

          installPhase = ''
            ${oldAttrs.installPhase}
            cp ${startScript} $out/bin/kotlinc-native-fix
          '';
        });
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = with pkgs; [
                hello
                bubblewrap
                kotlin-native-fix
                jdk
              ];

              enterShell = ''
                export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}";
              '';
            }
          ];
        };
      });
  };
}
