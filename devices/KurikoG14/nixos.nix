p @ {
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  extraModules ? [],
  # Optional
  home-manager,
  hm-config ? {},
  ...
}: let
  system = customVars.system;

  os-template = import "${root.os}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    modules =
      [
        ./configuration.nix

        "${root.base}/nixos/pkgs/docker-cuda.nix"

        # ./age-nixos.nix

        # Also import home here
        # No! this will cause problems:
        # https://www.reddit.com/r/NixOS/comments/112ekgm/comment/j8jngb3/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
        {
          imports = [
            home-manager.nixosModules.home-manager
          ];

          home-manager = {
            # useGlobalPkgs = true;
            # useUserPackages = true;

            extraSpecialArgs = hm-config.extraSpecialArgs;

            users.${username} = {
              imports = hm-config.modules;
            };
          };
        }

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

              boot.protectBinfmt = false;
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
          # new_mesa = pkgs.callPackage "${root.pkgs}/mesa.nix" {};
        in {
          # nixpkgs.overlays = [
          #   (final: prev: {
          #     mesa = prev.mesa.overrideAttrs (oldAttrs: rec {
          #       mesonFlags =
          #         oldAttrs.mesonFlags
          #         ++ [
          #           (lib.mesonEnable "gallium-va" false)
          #           (lib.mesonEnable "microsoft-clc" false)
          #         ];
          #       });
          #   })
          # ];

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

          services.avahi = {
            enable = true;
            nssmdns4 = true;
            nssmdns6 = true;
            publish = {
              enable = true;
              domain = true;
              addresses = true;
              workstation = true;
            };
          };

          # Enable hyperland
          # services.xserver.displayManager.startx.enable = true; = true;
          # services.displayManager.sddm.enable = true;
          services.xrdp.enable = true;
          services.xrdp.port = 3390;
          services.xserver.enable = true;
          services.xserver.desktopManager.xfce.enable = true;
          services.displayManager.defaultSession = "xfce";
          # services.xrdp.defaultWindowManager = "startxfce4";

          programs.hyprland = {
            enable = true;
            withUWSM = true; # recommended for most users
            xwayland.enable = true; # Xwayland can be disabled.
          };
          environment.sessionVariables.NIXOS_OZONE_WL = "1";

          environment.systemPackages = with pkgs; [
            avahi

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
      ]
      ++ extraModules;
  });
in
  os-template
