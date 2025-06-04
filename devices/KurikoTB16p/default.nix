{
  inputs,
  root,
  lib,
  genRepos,
  versionMap,
  ...
} @ p: let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    hostName = "KurikoTB16p";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};
  repos = genRepos system;

  # =========== change this to switch version ===========
  os-version = "stable";
  hm-version = "stable";
  # ====================================================

  nixpkgs-hm = versionMap.${hm-version}.nixpkgs;
  pkgs-hm = repos."pkgs-${hm-version}";
  home-manager = versionMap.${hm-version}.home-manager;

  nixpkgs-os = versionMap.${os-version}.nixpkgs;
  pkgs-os = repos."pkgs-${os-version}";

  # ====================================================
  hm-config = import "${root.base}/devices/KurikoG14/home.nix" (p
    // {
      inherit home-manager customVars repos;

      nixpkgs = nixpkgs-hm;
      pkgs = pkgs-hm;
    });

  os-config = import "${root.base}/devices/KurikoG14/nixos.nix" (p
    // {
      inherit home-manager customVars repos;

      nixpkgs = nixpkgs-os;
      pkgs = pkgs-os;

      inherit hm-config;

      extraModules = [
        ({...}: {
          # disable buggy windows vulkan, use cpu
          environment.sessionVariables = {
            VK_ICD_FILENAMES = lib.mkDefault "/run/opengl-driver/share/vulkan/icd.d/lvp_icd.x86_64.json";
          };
        })
      ];
    });
  # =======================================================================
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-config;

    nixosConfigurations.${hostName} =
      nixpkgs-os.lib.nixosSystem os-config;
  }
