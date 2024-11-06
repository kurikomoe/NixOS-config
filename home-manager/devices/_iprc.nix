# Partial iprc setup without sensitive infos

{ inputs, root, allRepos, versionMap, customVars, ... }:

let
  system = customVars.system;

  repos = allRepos.${system};
  template = import ./template.nix;
in
  template (with customVars; {
    inherit inputs root customVars versionMap repos;

    stateVersion = "24.05";

    extraNixPkgsOptions = {
      cudaSupport = true;
    };

    extraSpecialArgs = {
      # for proxychains
      proxy="http 127.0.0.1 8891";
    };

    modules = [
      ({config, inputs, nixpkgs, lib, pkgs, ...}:

      let
        shellScripts = with pkgs; [
         (pkgs.writeShellScriptBin "nixup"
          ''
              nix flake update --flake "$HOME/.nixos/home-manager";
              home-manager --flake "$HOME/.nixos/home-manager#${deviceName}.${username}" switch;
              nixdiff;
          '')

          (pkgs.writeShellScriptBin "nixdiff"
          ''
            echo ======= Current Home Manager Updates ==========
            nix store diff-closures \
              $(find $HOME/.local/state/nix/profiles -name "home-manager-*-link" | sort | tail -n2 | head -n1) \
              $HOME/.local/state/nix/profiles/home-manager
            nix store diff-closures \
              $(find $HOME/.local/state/nix/profiles -name "profile-*-link" | sort | tail -n2 | head -n1) \
              $HOME/.local/state/nix/profiles/profile
          '')

          (pkgs.writeShellScriptBin "git"
          ''
            LD_PRELOAD=/usr/lib64/libnss_ldap.so.2 \
              GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -F ~/.ssh/config" \
              fq ${pkgs.git}/bin/git $@
          '')
        ];
      in {
        imports = [
          ../packages/shells/fish

          ../packages/devs/common.nix
          ../packages/devs/langs

          ../packages/tools/ssh/iprc.nix
          ../packages/tools/git
          ../packages/tools/gnupg.nix
          ../packages/tools/vim
          ../packages/tools/tmux
          ../packages/tools/topgrade
          ../packages/tools/direnv.nix
          ../packages/tools/network.nix
          ../packages/tools/others.nix

          ../packages/tools/vscode.nix

          ../packages/tools/proxychains.nix

          # ../packages/libs/others.nix
          # ../packages/wsl
          # ../packages/libs/cuda.nix
          # ../packages/apps/podman.nix
          # ../packages/apps/db/mongodb.nix
        ];

        home.packages = with pkgs; [
          # repos.pkgs-iprc.glibc
          podman

          nss_ldap
          nss
        ] ++ (map (e: (lib.hiPrio e)) shellScripts);

        # nixpkgs.overlays = [
        #   (final: prev: {
        #     glibc = repos.pkgs-iprc.glibc;
        #     libgcc = repos.pkgs-iprc.libgcc;
        #   })
        # ];


        home.sessionVariables = {
          PROXYSERVER = "127.0.0.1:8891";
          all_proxy = "http://$PROXYSERVER";
          http_proxy = "http://$PROXYSERVER";
          https_proxy = "http://$PROXYSERVER";
          socks_proxy = "socks5://$PROXYSERVER";
        };

        programs = {
          git = {
            extraConfig = {
              http = {
                proxy = "http://127.0.0.1:8891";
              };
            };
          };
        };
      })
    ];
  })

