{ inputs, root, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;
    currentVersion = "unstable";

    hostName = "KurikoNixOS";
    deviceName = hostName;

    username = "kuriko";
    usernameFull = "KurikoMoe";

    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

in let
  template = import ./template.nix;
  utils = import ./utils.nix { inherit customVars; };
  customNixPkgsImport = utils.customNixPkgsImport;

  repos = {
    cuda = {
      "12.2" = customNixPkgsImport inputs.nixpkgs-cuda-12_2 {};
      "12.4" = customNixPkgsImport inputs.nixpkgs-cuda-12_4 {};
    };
  };

in
  template {
    inherit inputs customVars repos root;
    stateVersion = "24.05";
    modules = [
      {
        imports = [
          ../packages/wsl

          ../packages/shells/fish

          ../packages/devs/common.nix
          ../packages/devs/langs

          ../packages/tools

          ../packages/libs/others.nix

          ../packages/libs/cuda.nix
        ];
      }
    ];
  }
