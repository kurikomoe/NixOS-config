# Partial iprc setup without sensitive infos
{ inputs, root, allRepos, versionMap, customVars, ...  }:
let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  utils = import "${root.base}/common/utils.nix" {inherit system; };
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

  # os-template = import "${root.os}/template.nix";
  hm-template = import "${root.hm}/template.nix";
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" = home-manager.lib.homeManagerConfiguration (hm-template {
      inherit inputs root customVars repos;

      pkgs = pkgs-hm;

      stateVersion = "24.05";

      extraNixPkgsOptions = {
        cudaSupport = true;
      };

      extraSpecialArgs = {
        # for proxychains
        proxy = "http 127.0.0.1 8891";
      };

      modules = [
        ({
          config,
          inputs,
          nixpkgs,
          lib,
          pkgs,
          ...
        }: let
          shellScripts = with pkgs; [
            (pkgs.writeShellScriptBin "nixup"
              ''
                nix flake update --flake "$HOME/.nixos";
                home-manager --flake "$HOME/.nixos/${username}@${hostName}" switch;
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
          imports = utils.buildImports root.hm-pkgs [
            "./shells/fish"

            "./devs/common.nix"
            "./devs/langs"

            "./tools/ssh/iprc.nix"
            "./tools/git"
            "./tools/gnupg.nix"
            "./tools/vim"
            "./tools/tmux"
            "./tools/topgrade"
            "./tools/direnv.nix"
            "./tools/network.nix"
            "./tools/others.nix"

            "./tools/vscode-server.nix"

            "./tools/proxychains.nix"

            # ./libs/others.nix
            # ./wsl
            # ./libs/cuda.nix
            # ./apps/podman.nix
            # ./apps/db/mongodb.nix
          ];

          home.packages = with pkgs;
            [
              # repos.pkgs-iprc.glibc
              podman

              nss_ldap
              nss
            ]
            ++ (map (e: (lib.hiPrio e)) shellScripts);

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
    });
  }
