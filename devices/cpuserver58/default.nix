{
  inputs,
  root,
  allRepos,
  versionMap,
  ...
}:
if !builtins.pathExists ./customvars.nix
then {}
else let
  customVars = import ./customvars.nix;
  # -------------- custom variables --------------------

  system = customVars.system;

  kutils = import "${root.base}/common/kutils.nix" {inherit system inputs;};
  repos = allRepos.${system};

  # =========== change this to switch version ===========
  hm-version = "stable";
  # ====================================================

  nixpkgs-hm = versionMap.${hm-version}.nixpkgs;
  pkgs-hm = repos."pkgs-${hm-version}";
  home-manager = versionMap.${hm-version}.home-manager;
  # ====================================================

  hm-template = import "${root.hm}/template.nix" (with customVars; {
    inherit inputs root customVars repos;

    pkgs = pkgs-hm;

    stateVersion = "24.05";

    extraNixPkgsOptions = {
      cudaSupport = true;
    };

    extraSpecialArgs = {
      koptions = {
        topgrade.enable = false;
      };
    };

    overrideSecrets = [./age.nix];

    modules = [
      (inputs @ {pkgs, ...}: let
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
        ];
      in {
        imports = kutils.buildImports root.hm-pkgs [
          "./shells/fish"

          "./devs/common.nix"
          "./devs/tools.nix"
          # "./devs/langs"
          # "./devs/ide/jetbrains.nix"

          # "./libs/others.nix"

          "./tools"
          "./tools/git"
          "./tools/ssh"
          "./devs/ide/vscode/vscode-server.nix"

          # "./apps/podman.nix"
        ];

        programs.jetbrains-remote.enable = true;
        programs.jetbrains-remote.ides = with repos.pkgs-unstable.jetbrains; [
          pycharm-professional
          clion
        ];

        targets.genericLinux.enable = true;

        home.packages = with pkgs;
          [
            # overwrite the system nix
            # repos.pkgs-unstable.nix

            # numactl
            # libnl

            # Test gui
            # xorg.xeyes
            # mesa-demos
            # vulkan-tools

            # podman
          ]
          ++ (map (e: (lib.hiPrio e)) shellScripts);

        # services.podman = {
        #   enable = true;
        # };
      })
    ];
  });
in
  with customVars; {
    homeConfigurations."${username}@${hostName}" =
      home-manager.lib.homeManagerConfiguration hm-template;
  }
