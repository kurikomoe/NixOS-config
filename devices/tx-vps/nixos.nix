{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  hm-config,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};

  os-template = import "${root.os}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    modules = [
      ./bootstrap/configuration.nix
      ./bootstrap/hardware-configuration.nix

      ./age-nixos.nix

      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
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

      ({
        pkgs,
        lib,
        config,
        ...
      }: let
      in {
        disabledModules = [
          "services/networking/frp.nix"
        ];

        imports = [
          "${root.pkgs}/frp.nix"
        ];

        users.defaultUserShell = pkgs.fish;

        users.users.${username} = {
          shell = pkgs.fish;
          isNormalUser = true;
          group = "wheel";
          extraGroups = ["docker"];
          linger = true;

          hashedPassword = "$y$j9T$dzQwFZYmGRsWOegtolaSr0$Qj4h0ZO6FMF2/VGvJHPmgbC0cU2xgCabmi1EhdWa17A";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBzze5NuPIm4XiH/lbNmOVs/FCSsciG2m3oZg/T0Iob kuriko@KurikoG14"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0AYsIjb6hRAs5zgs8hnnNA/NGKIa9XDCvRW8H1CRseTQ2Z/z5yn2FmBB893e0wNim8AreYIgO0DsWQhr8j8iKxxXk1z3VAWMWT94N0vvENCCB7MjH9vK+c6Jp45Rk0nbqH2qXJBUKrOZyYwR/fwPN/AMM0H1h9ZhXc92qfhEfN7uqjv4lIwCEDBVuT4c6f/StoEFZJkuJiPv6YkGBISqWB+4Yje34o8P6CC0CGeE3FzVALJfmnRBoGW0oDdMDdDYhQktu02Y7YsITZXo4f5amAyJfNHYA0q4kVuPG5H2mGIKrL3xS96ZsIyhl28WX7ukvVwQqG3RopcHJH3pnoYOHueOOYqd44l+ZpZkoAzCPgFzXJmPB4qB4sQ96HwHhp04RzAND1BWMhCbaKPwOjV1Xf8LYWoICb1lRbj/EB5D/dgVPBmwewH6q8FzUBmS4AGGuMgOIIyfpMyYznsSZUJnrvvVvm8IP//wgp7stbno6DZ96QsOknkcDGzBFhFVbqvk= kuriko@KurikoG14"
          ];
        };

        networking.hostName = hostName;

        environment.systemPackages = with pkgs; [
          sshfs
          steam-run

          # docker
          dive # look into docker image layers
          podman-tui # status of containers in the terminal
          docker-compose
        ];

        services.mihomo = {
          enable = true;
          tunMode = true;
          configFile = config.age.secrets."clash/config.m.yaml".path;
        };

        # age.secrets."frp/frps.toml" = {
        #   mode = "400";
        # };

        services.frp = {
          enable = true;
          role = "server";
          settings = config.age.secrets."frp/frps.toml".path;
        };

        swapDevices = [
          {
            device = "/swapfile";
            size = 2048;
          }
        ];

        virtualisation.docker = {
          enable = true;
          enableOnBoot = true;
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };

        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 50;
        };

        # cannot enable on wsl, it will invoke building kernel
        # hardware.nvidia-container-toolkit.enable = true;
      })
    ];
  });
in
  os-template
