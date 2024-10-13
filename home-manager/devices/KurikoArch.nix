{ inputs, root, allRepos, versionMap, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;
    currentVersion = "stable";

    hostName = "KurikoArch";
    deviceName = hostName;

    username = "kuriko";
    usernameFull = "KurikoMoe";

    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

  repos = allRepos.${system};

  template = import ./template.nix;

in
  template (with customVars; {
    inherit inputs root customVars versionMap repos;

    stateVersion = "24.05";

    modules = [
      ({inputs, lib, pkgs, ... }: {
        imports = [
          ../packages/shells/fish

          ../packages/devs/common.nix
          ../packages/devs/langs

          ../packages/tools

          ../packages/libs/others.nix

          ../packages/libs/cuda.nix
        ];
      })
    ];
  })
