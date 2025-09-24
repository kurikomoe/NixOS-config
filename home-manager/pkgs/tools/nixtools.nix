{
  config,
  inputs,
  lib,
  pkgs,
  customVars,
  repos,
  ...
}: let
  home = config.home.homeDirectory;

  username = customVars.username;
  hostName = customVars.hostName;

  hms-text = ''
    home-manager --flake "${home}/.nixos#${username}@${hostName}" switch $@;
  '';

  oss-text = ''
    sudo nixos-rebuild --flake "${home}/.nixos#${hostName}" switch $@
  '';

  nixtools = with customVars; [
    (pkgs.writeShellScriptBin "hms" ''
      set -e
      ${hms-text}
      nixdiff-hm;
    '')

    (pkgs.writeShellScriptBin "oss" ''
      set -e
      ${oss-text}
      nixdiff-os;
    '')

    (pkgs.writeShellScriptBin "nixs" ''
      set -e
      ${oss-text}
      ${hms-text}
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

    (pkgs.writeShellScriptBin "push-hm" ''
      realpath ~/.local/state/nix/profiles/home-manager | cachix push kurikomoe
    '')

    (pkgs.writeShellScriptBin "push-nixos" ''
      realpath /nix/var/nix/profiles/system | cachix push kurikomoe
    '')
  ];
in
  with customVars; {
    home.packages = with pkgs;
      [
        # inputs.nix-search.packages.${system}.default
        nix-search-cli
        nix-index

        nix-tree # check disk usage

        nix-update
        nvfetcher

        # repos.pkgs-unstable.attic-client
        # repos.pkgs-unstable.attic-server
      ]
      ++ nixtools;

    home.shellAliases = {
      hm = lib.mkDefault "home-manager";
      hme = lib.mkDefault "$EDITOR '${home}/.nixos'";
      hmcd = lib.mkDefault "cd '${home}/.nixos/home-manager'";
      nxsearch = lib.mkDefault "nix search nixpkgs";
    };
  }
