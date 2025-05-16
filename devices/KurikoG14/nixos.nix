{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system inputs;};

  os-template = import "${root.os}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    modules = [
      ./configuration.nix

      "${root.base}/nixos/pkgs/docker-cuda.nix"

      # ./age-nixos.nix

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

      {
        imports = [
          "${root.base}/pkgs/nixos/wsl-drop-caches.nix"
        ];

        services."wsl-drop-caches".enable = true;
        services."wsl-drop-caches".interval = "30s";
      }

      # ../../common/builders
      # ../../common/builders/kurikoArch.local.nix

      {
        # nixpkgs.hostPlatform = {
        #   system = "x86_64-linux";
        #   gcc.arch = "x86-64-v3";
        #   # gcc.tune = "core-avx2";
        # };

        nix.settings.system-features = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
          "gccarch-x86-64-v3"
        ];
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
          isNormalUser = true;
          group = "wheel";
          extraGroups = ["docker"];
          linger = true;

          hashedPassword = "$6$aV8t5ljQBwHKHJdd$UO6BD7maFeOdOhH47..H2zMJaKmuyzRNb45/Q1iRtSQ87YcddkQmFeO0TF8mtyfY2rwhom3lXanBn5AT5QFYh1";
        };

        networking.hostName = hostName;

        i18n.supportedLocales = [
          "en_US.UTF-8/UTF-8"
          "zh_CN.UTF-8/UTF-8"
          "ja_JP.UTF-8/UTF-8"
        ];
        i18n.defaultLocale = "en_US.UTF-8";

        fonts.fontDir.enable = true;
        fonts.packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          liberation_ttf
          fira-code
          fira-code-symbols
          wqy_zenhei
          wqy_microhei
        ];

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
      })
    ];
  });
in
  os-template
