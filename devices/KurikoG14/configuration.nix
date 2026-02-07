# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
p @ {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Not appliable on WSL2
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelPatches = [
    {
      name = "Rust Support";
      patch = null;
      features = {
        rust = true;
      };
    }
  ];

  nix.settings = rec {
    keep-outputs = true;
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
    trusted-substituters = substituters;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://kurikomoe.cachix.org"
    ];
    trusted-public-keys = lib.mkAfter [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  boot.kernelModules = ["zram"];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 80;
    priority = 99;
  };
  systemd.services.init-zram = {
    description = "Manual zRAM Setup";
    after = ["dev-zram0.device"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [
      gawk # 提供 awk
      gnugrep # 提供 grep
      utillinux # 提供 mkswap, swapon, zramctl
      kmod # 提供 modprobe
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      swapoff /dev/zram0 || true

      # 2. 重置设备（这是关键，必须写入 1 来重置状态）
      echo 1 > /sys/block/zram0/reset || true

      # 3. 现在设置压缩算法
      # 注意：某些内核可能不支持 zstd，如果报错可以换成 lzo-rle
      echo zstd > /sys/block/zram0/comp_algorithm || echo lzo-rle > /sys/block/zram0/comp_algorithm

      # 4. 设置容量
      # 我们取总内存的一半。WSL2 的 MemTotal 单位是 kB。
      TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
      DISK_SIZE_BYTES=$((TOTAL_MEM_KB * 1024))
      echo $DISK_SIZE_BYTES > /sys/block/zram0/disksize

      # 5. 格式化并启用
      mkswap /dev/zram0
      swapon /dev/zram0 -p 100
    '';
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  nix.gc = lib.mkDefault {
    persistent = true;
    automatic = false;
    dates = "weekly";
    # options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  environment.variables.EDITOR = "vim";
  environment.systemPackages = with pkgs; [
    home-manager
    binutils
    vim
    wget
    curl
    htop
    which
    git
  ];

  programs = {
    zsh.enable = true;
    fish.enable = true;
  };

  time.timeZone = "Asia/Shanghai";

  services = {
    # conflic with time.timeZone
    # automatic-timezoned.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
