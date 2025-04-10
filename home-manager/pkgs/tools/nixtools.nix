{
  config,
  inputs,
  lib,
  pkgs,
  customVars,
  ...
}: let
  home = config.home.homeDirectory;

  nixtools = with customVars; [
    (pkgs.writeShellScriptBin "hms" ''
      set -e
      home-manager --flake "${home}/.nixos#${username}@${hostName}" switch $@;
      nixdiff-hm;
    '')

    (pkgs.writeShellScriptBin "nixs" ''
      set -e
      # for nix 2.18
      sudo nixos-rebuild --flake "$HOME/.nixos#${hostName}" switch $@;
      home-manager --flake "$HOME/.nixos#${username}@${hostName}" switch $@;
      nixdiff;
    '')

    (pkgs.writeShellScriptBin "nixup" ''
      sudo true
      nix flake update --flake "$HOME/.nixos";
      nixs $@
    '')

    (pkgs.writeShellScriptBin "nixdiff-os" ''
      set -e
      echo ======= Current System Updates ==========
      nix store diff-closures \
        $(find /nix/var/nix/profiles -name "system-*-link" | sort | tail -n2 | head -n1) \
        /var/run/current-system
    '')

    (pkgs.writeShellScriptBin "nixdiff-hm" ''
      set -e
      echo ======= Current Home Manager Updates ==========
      # nix store diff-closures \
      #   $(find $HOME/.local/state/nix/profiles -name "home-manager-*-link" | sort | tail -n2 | head -n1) \
      #   $HOME/.local/state/nix/profiles/home-manager
      nix store diff-closures \
        $(find $HOME/.local/state/nix/profiles -name "profile-*-link" | sort | tail -n2 | head -n1) \
        $HOME/.local/state/nix/profiles/profile
    '')

    (pkgs.writeShellScriptBin "nixdiff" ''
      set -e
      nixdiff-os
      echo ""
      nixdiff-hm
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
in
  with customVars; {
    home.packages = with pkgs;
      [
        # inputs.nix-search.packages.${system}.default
        nix-search-cli
        nix-index
      ]
      ++ nixtools;

    home.shellAliases = {
      hm = lib.mkDefault "home-manager";
      hme = lib.mkDefault "$EDITOR '${home}/.nixos'";
      hmcd = lib.mkDefault "cd '${home}/.nixos/home-manager'";
      nxsearch = lib.mkDefault "nix search nixpkgs";
    };
  }
