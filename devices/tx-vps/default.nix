{
  inputs,
  root,
  lib,
  allRepos,
  versionMap,
  ...
} @ p: let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    hostName = "KurikoTXCloud";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};
  repos = allRepos.${system};

  # =========== change this to switch version ===========
  hm-version = "stable";
  os-version = "stable";
  # ====================================================
  nixpkgs-hm = versionMap.${hm-version}.nixpkgs;
  pkgs-hm = repos."pkgs-${hm-version}";
  home-manager = versionMap.${hm-version}.home-manager;

  nixpkgs-os = versionMap.${os-version}.nixpkgs;
  pkgs-os = repos."pkgs-${os-version}";
  # ====================================================
  # Put into nixos build config
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
  with customVars; rec {
    nixosConfigurations.${hostName} =
      nixpkgs-os.lib.nixosSystem os-config;

    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-config;

    deploy = {
      nodes.${hostName} = {
        hostname = "c.0v0.io";

        profiles.system = {
          user = "root";
          sshUser = "root";
          fastConnection = false;
          autoRollback = true;
          magicRollback = true;
          remoteBuild = false;
          path =
            inputs.deploy-rs.lib.${system}.activate.nixos
            nixosConfigurations.${hostName};
        };

        # profile.home-manager = {
        #   user = "kuriko";
        #   sshUser = "root";
        #   autoRollback = true;
        #   magicRollback = true;
        #   remoteBuild = false;
        #   path = inputs.deploy-rs.lib.${system}.activate.home-manager
        #     homeConfigurations."${username}@${hostName}";
        # };
      };
    };
  }
