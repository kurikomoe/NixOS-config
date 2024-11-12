{ inputs, root, allRepos, versionMap, ...  }:
let
  # -------------- custom variables --------------------
  system = "x86_64-linux";

  customVars = rec {
    inherit system;

    hostName = "KurikoNixOS";

    username = "kuriko";
    usernameFull = "KurikoMoe";
    userEmail = "kurikomoe@gmail.com";

    homeDirectory = /home/${username};
  };

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

  os-template = import "${root.os}/template.nix";
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

      modules = [
        ({pkgs, ...}: {
          imports = utils.buildImports root.hm-pkgs [
            "./wsl"

            "./shells/fish"

            "./devs/common.nix"
            "./devs/langs"

            "./tools"

            "./libs/others.nix"

            "./libs/cuda.nix"

            "./apps/db/mongodb.nix"

            "./gui/fonts.nix"
            "./gui/browsers"
            "./gui/jetbrains.nix"

            # "${root.hm-pkgs}/apps/podman.nix"
          ];

          home.packages = with pkgs; [
            # Test gui
            xorg.xeyes
            mesa-demos
            vulkan-tools
          ];
        })
      ];
    });

    nixosConfigurations.${hostName} = nixpkgs-os.lib.nixosSystem (os-template {
      inherit inputs root customVars repos;

      pkgs = pkgs-os;

      modules = [
        ./configuration.nix

        inputs.nixos-wsl.nixosModules.default {
          system.stateVersion = "24.05";
          wsl = {
            enable = true;
            defaultUser = username;
            interop.includePath = false;
            interop.register = true;
            usbip.enable = true;
            useWindowsDriver = true;
            wslConf = {
              user.default = username;
              automount.ldconfig = true;
              automount.enabled = true;
              interop.enabled = true;
              interop.appendWindowsPath = false;
            };
          };
        }

        ({ pkgs, lib, ...  }:
        let
          new_mesa = pkgs.callPackage "${root.pkgs}/mesa.nix" {};
        in {
          users.defaultUserShell = pkgs.zsh;

          users.users.${username} = {
            shell = pkgs.fish;
            extraGroups = ["docker"];
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
    });
  }
