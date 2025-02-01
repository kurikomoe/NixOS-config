# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
p @ {
  config,
  pkgs,
  lib,
  ...
}: let
  #!FIXME(kuriko): Change this according to vdisk on vps
  vpsDisk = "/dev/vda";
in {
  imports = [
  ];

  # Not appliable on WSL2
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [
    "audit=0"
    "net.ifnames=0"
    "mitigations=off"
  ];

  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
    systemd.enable = true;
  };

  boot.loader.grub = {
    configurationLimit = 3; # avoid using up the /boot disk space
    efiSupport = true;
    devices = ["/dev/vda"];
    efiInstallAsRemovable = true;
  };

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = "$y$j9T$dzQwFZYmGRsWOegtolaSr0$Qj4h0ZO6FMF2/VGvJHPmgbC0cU2xgCabmi1EhdWa17A";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBzze5NuPIm4XiH/lbNmOVs/FCSsciG2m3oZg/T0Iob kuriko@KurikoG14"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0AYsIjb6hRAs5zgs8hnnNA/NGKIa9XDCvRW8H1CRseTQ2Z/z5yn2FmBB893e0wNim8AreYIgO0DsWQhr8j8iKxxXk1z3VAWMWT94N0vvENCCB7MjH9vK+c6Jp45Rk0nbqH2qXJBUKrOZyYwR/fwPN/AMM0H1h9ZhXc92qfhEfN7uqjv4lIwCEDBVuT4c6f/StoEFZJkuJiPv6YkGBISqWB+4Yje34o8P6CC0CGeE3FzVALJfmnRBoGW0oDdMDdDYhQktu02Y7YsITZXo4f5amAyJfNHYA0q4kVuPG5H2mGIKrL3xS96ZsIyhl28WX7ukvVwQqG3RopcHJH3pnoYOHueOOYqd44l+ZpZkoAzCPgFzXJmPB4qB4sQ96HwHhp04RzAND1BWMhCbaKPwOjV1Xf8LYWoICb1lRbj/EB5D/dgVPBmwewH6q8FzUBmS4AGGuMgOIIyfpMyYznsSZUJnrvvVvm8IP//wgp7stbno6DZ96QsOknkcDGzBFhFVbqvk= kuriko@KurikoG14"
      ];
    };
  };

  networking.hostName = lib.mkDefault "KurikoTXCloud";
  systemd.network.enable = true;
  systemd.network.networks.eth0 = {
    matchConfig.Name = "eth0";
    address = ["10.0.16.16/22"];
    gateway = ["10.0.16.1"];
    routes = [
      {
        Destination = "183.60.82.98";
        Gateway = "10.0.16.1";
      }
      {
        Destination = "183.60.83.19";
        Gateway = "10.0.16.1";
      }
    ];
  };
  services.resolved.enable = true;
  networking.nameservers = [
    "119.29.29.29"
    "223.5.5.5"
    "1.1.1.1"
  ];
  networking.useNetworkd = true;
  networking.useDHCP = false;

  fileSystems."/boot" = {
    device = "/dev/vda2";
    fsType = "vfat";
    options = ["umask=0077"];
  };

  fileSystems."/" = {
    device = "/dev/vda3";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime"];
  };

  services.btrfs.autoScrub.enable = true;

  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };

  networking.firewall.enable = false;

  nix.settings = {
    keep-outputs = true;
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
    trusted-substituters = [
      https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
      https://mirrors.ustc.edu.cn/nix-channels/store
      https://nix-community.cachix.org
    ];
    substituters = [
      https://mirrors.ustc.edu.cn/nix-channels/store
      https://mirror.sjtu.edu.cn/nix-channels/store
      https://nix-community.cachix.org
    ];
    trusted-public-keys = lib.mkAfter [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "vi";
  environment.systemPackages = with pkgs; [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
