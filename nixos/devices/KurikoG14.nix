{ inputs, root, allRepos, versionMap, ... }:

let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    version = "stable";

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

      ({ pkgs, ... }: {
        users.defaultUserShell = pkgs.zsh;

        users.users.${username} = {
          shell = pkgs.fish;
          extraGroups = [ "docker" ];
        };

        networking.hostName = hostName;

        environment.variables = {
          LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
        };

        environment.systemPackages = with pkgs; [
          sshfs
          steam-run

          khronos-ocl-icd-loader
          ocl-icd
          intel-ocl
          intel-compute-runtime

          docker
          docker-compose
        ];

        virtualisation.docker.enable = true;

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
