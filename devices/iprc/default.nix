# Partial iprc setup without sensitive infos
{
  inputs,
  root,
  lib,
  genRepos,
  versionMap,
  ...
}:
if !builtins.pathExists ./customvars.nix
then {}
else let
  customVars = import ./customvars.nix;
  # -------------- custom variables --------------------

  system = "x86_64-linux";

  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};
  repos = genRepos system;

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
      inherit inputs root customVars repos lib;

      pkgs = pkgs-hm;

      stateVersion = "24.05";

      extraNixPkgsOptions = {
        cudaSupport = true;
      };

      extraSpecialArgs = {
        # for proxychains
        koptions.proxychains.proxy = "http 127.0.0.1 8891";
      };

      modules = [
        ({
          config,
          inputs,
          nixpkgs,
          lib,
          pkgs,
          repos,
          ...
        }: let
          shellScripts = with pkgs; [
            (pkgs.writeShellScriptBin "hms" ''
              set -e
              home-manager --flake "path:$HOME/.nixos#${username}@${hostName}" switch;
              nixdiff;
            '')

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

            (pkgs.writeShellScriptBin "fqgit"
              ''
                LD_PRELOAD=/usr/lib64/libnss_ldap.so.2 \
                  GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -F ~/.ssh/config" \
                  ${pkgs.proxychains-helper}/bin/fq ${pkgs.git}/bin/git $@
              '')
          ];
        in {
          imports =
            [
            ]
            ++ kutils.buildImports root.hm-pkgs [
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
              # "./tools/others.nix"

              "./devs/ide/vscode/vscode-server.nix"

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

              # tsocks
              # adguardhome
              dnsproxy

              nss_ldap
              nss

              # Terminals
              wget
              wget2
              curl
              htop
              nvtopPackages.full
              less
              tree
              which
              util-linux
              killall

              cowsay

              # hardwares
              pciutils
              ethtool

              gtop
              dust # du-dust
              fd # find
              fend
              ripgrep # search tools
              file
              mlocate

              ncdu
              jq
              dos2unix

              # network
              dig
              lsof
              lshw
              hwloc
              iftop
              nettools
              # tcpdump
              # traceroute
              # mtr

              # caddy
              aria2

              # media
              # yt-dlp
              # ffmpeg_7-full

              # netdisk
              # rclone
              # rsync

              # diskio
              iotop

              # others
              macchina
              fastfetch
              # topgrade

              # task control
              just
              pueue

              # provide lddtree command for better ldd experience
              pax-utils

              # nix tools
              nix-output-monitor # aka nom
            ]
            ++ (map (e: (lib.hiPrio e)) shellScripts);

          # nixpkgs.overlays = [
          #   (final: prev: {
          #     glibc = repos.pkgs-iprc.glibc;
          #     libgcc = repos.pkgs-iprc.libgcc;
          #   })
          # ];

          targets.genericLinux.enable = true;

          home.sessionVariables = {
            PROXYSERVER = "127.0.0.1:8891";
            all_proxy = "http://$PROXYSERVER";
            http_proxy = "http://$PROXYSERVER";
            https_proxy = "http://$PROXYSERVER";
            socks_proxy = "socks5://$PROXYSERVER";
            LD_PRELOAD = "/usr/lib64/libnss_ldap.so.2";
          };

          programs.atuin = lib.mkForce {
            enable = true;
            enableFishIntegration = true;
            settings = {
              key_path = config.age.secrets."atuin/key".path;
              db_path = "/tmp/${username}/atuin/history.db";
              auto_sync = true;
              sync_frequency = "5m";
            };
          };

          programs = {
            git = {
              extraConfig = {
                http.proxy = "http://127.0.0.1:8891";
              };
            };
          };
        })
      ];
    });
  }
