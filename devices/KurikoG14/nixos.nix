{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};

  os-template = import "${root.os}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    modules = [
      ./configuration.nix

      # Also import home here
      # No! this will cause problems:
      # https://www.reddit.com/r/NixOS/comments/112ekgm/comment/j8jngb3/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      # {
      #   imports = [
      #     home-manager.nixosModules.home-manager
      #   ];
      #
      #   home-manager = {
      #     # useGlobalPkgs = true;
      #     # useUserPackages = true;
      #
      #     extraSpecialArgs = hm-template.extraSpecialArgs;
      #
      #     users.${username} = {
      #       imports = hm-template.modules;
      #     };
      #   };
      # }

      inputs.nixos-wsl.nixosModules.default
      {
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

      ({
        pkgs,
        lib,
        config,
        ...
      }: let
        new_mesa = pkgs.callPackage "${root.pkgs}/mesa.nix" {};
      in {
        users.defaultUserShell = pkgs.zsh;

        users.users.${username} = {
          shell = pkgs.fish;
          extraGroups = ["docker"];
          linger = true;
        };

        networking.hostName = hostName;

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
in
  os-template
