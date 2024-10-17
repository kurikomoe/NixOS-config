{ config, inputs, lib, pkgs, customVars, ... }:
let
  home = config.home.homeDirectory;

  nixtools = with customVars; [
    (pkgs.writeShellScriptBin "nixup" ''
      set -e
      sudo true;
      nix flake update "$HOME/.nixos/nixos";
      nix flake update "$HOME/.nixos/home-manager";

      sudo nixos-rebuild --flake "$HOME/.nixos/nixos#${hostName}" switch;
      home-manager --flake "$HOME/.nixos/home-manager#${deviceName}.${username}" switch;

      nixdiff;
    '')

    (pkgs.writeShellScriptBin "nixdiff" ''
      set -e
      echo ======= Current System Updates ==========
      nix store diff-closures /var/run/current-system \
        $(find /nix/var/nix/profiles -name "system-*-link" | sort | tail -n2 | head -n1)

      echo ======= Current Home Manager Updates ==========
      nix store diff-closures  \
        $(find $HOME/.local/state/nix/profiles -name "home-manager-*-link" | sort | tail -n2 | head -n1) \
        $HOME/.local/state/nix/profiles/home-manager
      nix store diff-closures \
        $(find $HOME/.local/state/nix/profiles -name "profile-*-link" | sort | tail -n2 | head -n1) \
        $HOME/.local/state/nix/profiles/profile
    '')

    (pkgs.writeShellScriptBin "nixgc" ''
      set -e
      sudo nix-collect-garbage --delete-older-than 7d
      nix-collect-garbage --delete-older-than 7d
    '')

    (pkgs.writeShellScriptBin "nixkeep" ''
      set -e
      test -O /nix/var/nix/gcroots/per-user/$USER ||
      sudo -u$USER mkdir -p /nix/var/nix/gcroots/per-user/$USER;
      mkdir -p /nix/var/nix/gcroots/per-user/$USER/$PWD;
      ln -sf $PWD /nix/var/nix/gcroots/per-user/$USER/$PWD/;
    '')
  ];

in with customVars; {
  home.packages = [
    # inputs.nix-search.packages.${system}.default
    pkgs.nix-search-cli
  ] ++ nixtools;

  home.shellAliases = {
    hm = lib.mkDefault "home-manager";
    hme = lib.mkDefault "$EDITOR '${home}/.nixos/home-manager'";
    hms = lib.mkDefault "home-manager --flake '${home}/.nixos/home-manager#${deviceName}.${username}' switch";
    hmsdr = lib.mkDefault "home-manager --flake '${home}/.nixos/home-manager#${deviceName}.${username}' switch --dry-run";
    hmcd = lib.mkDefault "cd '${home}/.nixos/home-manager'";
    nxsearch = lib.mkDefault "nix search nixpkgs";
  };
}
