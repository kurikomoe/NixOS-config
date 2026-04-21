{
  inputs,
  root,
  lib,
  genRepos,
  defaultRepos,
  kutils,
  versionMap,
  ...
} @ p: let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    hostName = "KurikoG14";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = "/home/${username}";
  };

  repos = defaultRepos;

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
  hm-config = import ./home.nix (p
    // {
      inherit home-manager customVars repos;

      nixpkgs = nixpkgs-hm;
      pkgs = pkgs-hm;
    });

  os-config = import ./nixos.nix (p
    // {
      inherit home-manager customVars repos hm-config;

      nixpkgs = nixpkgs-os;
      pkgs = pkgs-os;
    });
  # =======================================================================
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-config;

    nixosConfigurations.${hostName} =
      nixpkgs-os.lib.nixosSystem os-config;
  }
