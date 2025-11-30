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
          "${root.pkgs}/nixos/frp.nix"
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
          acme-sh

          sshfs
          steam-run

          openvpn
          iptables

          # docker
          # dive # look into docker image layers
          # podman-tui # status of containers in the terminal
          docker-compose
        ];

        services.mihomo = {
          enable = true;
          tunMode = true;
          configFile = config.age.secrets."clash/config.m.yaml".path;
        };

        services.journald.extraConfig = ''
          SystemMaxUse=100M
          SystemMaxFileSize=50M
          MaxFileSec=1week
        '';

        services.headscale = rec {
          enable = false;
          address = "0.0.0.0";
          port = 3333;
          settings = {
            dns.base_domain = "c.0v0.io";
            tls_key_path = "/etc/keys/c.0v0.io_ecc/c.0v0.io.key";
            tls_cert_path = "/etc/keys/c.0v0.io_ecc/c.0v0.io.cer";
            server_url = "https://c.0v0.io:${toString port}";
            derp.server = {
              enabled = true;
              region_id = "901";
              region_code = "KurikoHeadCrab";
              region_name = "Kuriko's HeadCrab DERP";
              stun_listen_addr = "0.0.0.0:3478";
              ipv4 = "122.51.29.4";
              automatically_add_embedded_derp_region = true;
            };
          };
        };

        services.tailscale = {
          enable = false;
          # derper.enable = true;
          # derper.domain = "c.0v0.io";
          # derper.verifyClients = true;
        };

        # age.secrets."frp/frps.toml" = {
        #   mode = "400";
        # };

        services.frp = {
          enable = true;
          role = "server";
          settings = config.age.secrets."frp/frps.toml".path;
        };

        services.zerotierone = {
          enable = true;
          joinNetworks = [
            "acb32915af0ad9ab"
          ];
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

        services.rustdesk-server = {
          enable = false;
          relay.enable = true;
          # signal.enable = true;
          # signal.relayHosts = [
          #   # HIDE
          # ];
        };

        # cannot enable on wsl, it will invoke building kernel
        # hardware.nvidia-container-toolkit.enable = true;
      })
    ];
  });
in
  os-template
