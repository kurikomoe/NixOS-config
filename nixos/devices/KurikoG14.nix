{ inputs, root, allRepos, versionMap, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    version = "unstable";

    deviceName = "KurikoG14";

    hostName = "KurikoNixOS";

    username = "kuriko";
  };

  repos = allRepos.${system};

  template = import ./template.nix;

in
  template (with customVars; {
    inherit inputs root customVars versionMap repos;

    modules = [
      inputs.nixos-wsl.nixosModules.default {
          system.stateVersion = "24.05";
          wsl.enable = true;
          wsl.defaultUser = username;
          wsl.interop.includePath = false;
          wsl.interop.register = true;
          wsl.usbip.enable = true;
          wsl.useWindowsDriver = true;
          wsl.wslConf.automount.ldconfig = true;
          wsl.wslConf.automount.enabled = true;
          wsl.wslConf.interop.enabled = true;
          wsl.wslConf.interop.appendWindowsPath = false;
          wsl.wslConf.user.default = username;
      }

      ({ pkgs, lib, ... }: let
        # mesa_new = pkgs.mesa.overrideAttrs (oldAttrs: rec {
        #   mesonFlags = oldAttrs.mesonFlags ++ [
        #     (lib.mesonEnable "gallium-va" true)
        #     (lib.mesonEnable "microsoft-clc" true)
        #   ];
        # });
      in {
        users.defaultUserShell = pkgs.zsh;

        users.users.${username} = {
          shell = pkgs.fish;
          extraGroups = [ "docker" ];
          linger = true;
        };

        networking.hostName = hostName;

        environment.variables = {
          LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
          MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
        };

        environment.systemPackages = with pkgs; [
          sshfs
          steam-run

          libva

          # docker
          dive # look into docker image layers
          podman-tui # status of containers in the terminal
          docker-compose
        ];

        # cannot enable on wsl, it will invoke building kernel
        # hardware.nvidia-container-toolkit.enable = true;

        virtualisation = {
          docker = {
            enable = true;
            autoPrune.enable = true;
          };

          # podman = {
          #   enable = true;
          #   autoPrune.enable = true;
          # };

          # oci-containers ={
          #   backend = "podman";
          #   containers = {
          #     container-name = {
          #       image = "container-image";
          #       autoStart = true;
          #       ports = [ "127.0.0.1:1234:1234" ];
          #     };
          #   };
          # };
        };

        services = {
          openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "prohibit-password";
              PasswordAuthentication = false;
            };
          };
        };
      })
    ];
  })
