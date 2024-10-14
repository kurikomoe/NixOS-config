{
  inputs,
  root,
  customVars,
  versionMap,
  repos,
  modules ? [],
  extraNixPkgsOptions ? {},
  stateVersion ? "24.05",
  ...
}@p:

let
  system = customVars.system;
  utils = import ../../common/utils.nix { inherit system; };

  version = customVars.version;

  nixpkgs = versionMap.${version}.nixpkgs;
  home-manager = versionMap.${version}.home-manager;

  pkgs = repos."pkgs-${version}";

in with customVars; {
  homeConfigurations."${deviceName}.${username}" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      inherit customVars inputs root;

      # locked pkgs
      inherit repos;
    };

    modules = p.modules ++ [
      # -------------- load agenix secrets ----------------
      {
        imports = [ ../packages/age.nix ];
        home.packages = [ inputs.agenix.packages.${system}.default ];
      }

      # -------------- enable nur & others overlays ----------------
      {
        # This should be safe, since nur use username as namespace.
        nixpkgs.overlays = [ inputs.nur.overlay ];
        home.packages = [ ];
      }
      # ------------ user nix settings --------------------
      ({config, inputs, lib, ... }: {
        imports = [
          ../packages/tools/nixtools.nix
        ];

        home.stateVersion = stateVersion;
        home.username = username;
        home.homeDirectory = homeDirectory;

        news = {
          display = "show";
        };

        nix.package = pkgs.nix;
        nix.settings = lib.recursiveUpdate utils._commonNixPkgsConfig.settings {
          trusted-users = [ username ];
        };

        nix.gc = lib.mkDefault {
          automatic = true;
          frequency = "weekly";
        };

        # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
        nix.extraOptions = ''
          !include ${config.age.secrets."nix/access-tokens".path}
          !include ${config.age.secrets."nix/cachix.nix.conf".path}
        '';

        nixpkgs.config = {
          allowUnfree = true;
        };

        xdg.enable = true;

        home.file."${config.xdg.configHome}/current-home-packages".text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
            formatted;


        home.packages = with pkgs; [
          (lib.lowPrio vim)
          (lib.lowPrio neovim)
        ] ++ (p.packages or []);

        home.sessionVariables = {
          EDITOR = lib.mkDefault "nvim";
        };

        programs = lib.mkDefault {
          home-manager.enable = true;

          ssh = lib.mkDefault {
            enable = true;
            compression = true;
            forwardAgent = true;
          };

          fish = lib.mkDefault {
            enable = true;
          };
        };

        services = lib.mkDefault {};
      })
    ];
  };
}
