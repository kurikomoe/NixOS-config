{
  description = "A template that shows all standard flake outputs";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    # nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.05/nixexprs.tar.xz";
    # nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";

    # Move home-manager to standalone edition
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # --------------------- Third Party inputs ---------------------
    nix-alien.url = "github:thiagokokada/nix-alien";

    nixos-vscode-server.url = "https://github.com/msteen/nixos-vscode-server/tarball/master";

    # --------------------- Tmux Plugins ---------------------
    tmux-themepack = {
      url = "github:jimeh/tmux-themepack/master";
      flake = false;
    };

    # --------------------- Secrets Management ---------------------
    agenix.url = "github:ryantm/agenix";
  };

  # Outputs
  outputs = inputs@{ self, ... }:
  let
    # -------------- custom variables --------------------
    system = "x86_64-linux";

    customVars = {
      inherit system;
      hostName = "KurikoNixOS";
      userName = "kuriko";
    };


    # ----------------- reimport inputs ------------------
    nixpkgs = inputs.nixpkgs;
    # nixpkgs = inputs.nixpkgs-unstable;

    # -------------- pkgs versions ------------------
    lockedVersion = {
      cuda = {
        # "12.2" = import inputs.nixpkgs-cuda-12_2 {
        #   inherit system;
        #   config.allowUnfree = true;
        # };
      };
    };

  in with customVars; {
    # Used with `nixos-rebuild --flake [path]#<hostname>`
    nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {

      specialArgs = {
         inherit customVars lockedVersion inputs;
      };

      modules = [
        ./configuration.nix
        ./configuration_flake.nix

        inputs.nixos-wsl.nixosModules.default {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = userName;
            wsl.interop.includePath = false;
            wsl.interop.register = true;
            wsl.usbip.enable = true;
            wsl.useWindowsDriver = true;
            wsl.wslConf.automount.ldconfig = true;
            wsl.wslConf.automount.enabled = true;
            wsl.wslConf.interop.enabled = true;
            wsl.wslConf.interop.appendWindowsPath = false;
            wsl.wslConf.user.default = userName;
        }

        # agenix.nixosModules.default

        #inputs.home-manager.nixosModules.home-manager {
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;

        #   home-manager.users.${userName} = import ./home;

        #   home-manager.extraSpecialArgs = {
        #     inherit customVars;
        #     root = "${self}";
        #     inputs = self.inputs;
        #   };
        #}
      ];
    };
  };
}
