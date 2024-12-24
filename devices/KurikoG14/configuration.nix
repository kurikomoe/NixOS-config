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

  nix.settings = {
    keep-outputs = true;
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
    trusted-substituters = [
      https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
      https://mirrors.ustc.edu.cn/nix-channels/store
      # https://cache.nixos.org
      https://nix-community.cachix.org
    ];
    substituters = [
      https://mirrors.ustc.edu.cn/nix-channels/store
      # https://mirror.sjtu.edu.cn/nix-channels/store
      # https://cache.nixos.org
      https://nix-community.cachix.org
    ];
    trusted-public-keys = lib.mkAfter [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  nix.gc = lib.mkDefault {
    persistent = true;
    automatic = true;
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
    nix-ld = {
      enable = true;
      libraries = with pkgs;
        []
        ++ (pkgs.steam.args.multiPkgs pkgs);
    };
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
