{ config, inputs, lib, pkgs, customVars, ... }:

with customVars; {
  home.packages = [
    # inputs.nix-search.packages.${system}.default
    pkgs.nix-search-cli
  ];

  home.shellAliases = {
    hm = lib.mkDefault "home-manager";
    hme = lib.mkDefault "$EDITOR '${config.xdg.configHome}/home-manager'";
    hms = lib.mkDefault "home-manager --flake '${config.home.homeDirectory}/.nixos/home-manager#${deviceName}' switch";
    hmsdr = lib.mkDefault "home-manager --flake '${config.home.homeDirectory}/.nixos/home-manager#${deviceName}' switch --dry-run";
    hmcd = lib.mkDefault "cd '${config.xdg.configHome}/home-manager'";

    nixdiff = ''
      set -e
      echo ======= Current System Updates ==========
      nix store diff-closures /var/run/current-system \
        (find /nix/var/nix/profiles -name "system-*-link" | sort | tail -n2 | head -n1)

      echo ======= Current Home Manager Updates ==========
      nix store diff-closures  \
        (find ${config.home.homeDirectory}/.local/state/nix/profiles -name "home-manager-*-link" | sort | tail -n2 | head -n1) \
        ${config.home.homeDirectory}/.local/state/nix/profiles/home-manager
      nix store diff-closures \
        (find ${config.home.homeDirectory}/.local/state/nix/profiles -name "profile-*-link" | sort | tail -n2 | head -n1) \
        ${config.home.homeDirectory}/.local/state/nix/profiles/profile

      echo "============= DONE ================="
    '';

    nixup = ''
      set -e
      sudo true;
      nix flake update "${config.home.homeDirectory}/.nixos/nixos";
      nix flake update "${config.home.homeDirectory}/.nixos/home-manager";

      sudo nixos-rebuild --flake "${config.home.homeDirectory}/.nixos/nixos" switch;
      home-manager --flake "${config.home.homeDirectory}/.nixos/home-manager#${deviceName}" switch;

      nixdiff;
      echo "============= DONE ================="
    '';

    nixgc = ''
      set -e
      sudo nix-collect-garbage --delete-older-than 7d
      nix-collect-garbage --delete-older-than 7d
    '';

    nixkeep = ''
      test -O /nix/var/nix/gcroots/per-user/$USER ||
        sudo -u$USER mkdir -p /nix/var/nix/gcroots/per-user/$USER;
      mkdir -p /nix/var/nix/gcroots/per-user/$USER/$PWD;
      ln -sf $PWD /nix/var/nix/gcroots/per-user/$USER/$PWD/;
    '';

    nxsearch = lib.mkDefault "nix search nixpkgs";
  };
}
