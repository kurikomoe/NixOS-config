p@{ inputs, pkgs, customVars, ... }:

{
  nix.settings = {
    trusted-users = [ customVars.userName ];

    substituters = [
      https://mirrors.ustc.edu.cn/nix-channels/store
      https://mirror.sjtu.edu.cn/nix-channels/store
      https://cache.nixos.org
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.${customVars.userName} = {
    shell = pkgs.fish;
    extraGroups = [ "docker" ];
  };

  networking.hostName = customVars.hostName;

  environment.variables = {
    LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
  };

  environment.systemPackages = with pkgs; [
    steam-run
    inputs.nix-alien.packages.${system}.nix-alien

    # inputs.agenix.packages.${system}.default

    docker
    docker-compose

    pinentry-all
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
}
