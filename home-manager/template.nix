{
  inputs,
  root,
  pkgs,
  customVars,
  repos,
  modules ? [],
  extraSpecialArgs ? {},
  extraNixPkgsOptions ? {},
  stateVersion ? "24.05",
  ...
} @ p: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};
in
  with customVars; {
    inherit pkgs;

    extraSpecialArgs =
      {
        inherit customVars inputs root;

        # locked pkgs
        inherit repos;

        koptions = import ./options.nix;
      }
      // extraSpecialArgs;

    modules =
      p.modules
      ++ [
        # -------------- load agenix secrets ----------------
        {
          imports = ["${root.hm}/pkgs/age.nix"];
          home.packages = [inputs.agenix.packages.${system}.default];
        }

        # -------------- enable nur & others overlays ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [inputs.nur.overlay];
          home.packages = [];
        }
        # ------------ user nix settings --------------------
        ({
          config,
          inputs,
          lib,
          ...
        }: {
          imports = [
            "${root.hm-pkgs}/tools/nixtools.nix"
          ];

          home.stateVersion = stateVersion;

          home.username = lib.mkDefault username;
          home.homeDirectory = lib.mkDefault homeDirectory;

          news = {
            display = "show";
          };

          nix = {
            package = lib.mkDefault repos.pkgs-unstable.nix;
            gc = lib.mkDefault {
              automatic = true;
              frequency = "weekly";
            };
            settings = lib.recursiveUpdate utils._commonNixPkgsConfig.settings {
              trusted-users = [username];
              sandbox = true;
            };
            # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
            extraOptions = ''
              !include ${config.age.secrets."nix/access-tokens".path}
              !include ${config.age.secrets."nix/cachix.nix.conf".path}
            '';
          };

          nixpkgs.config = {
            allowUnfree = true;
          };

          xdg.enable = true;

          home.file."${config.xdg.configHome}/current-home-packages".text = let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
            formatted;

          home.packages = with pkgs;
            [
              gnutar

              stdenv.cc.cc.lib

              (lib.lowPrio vim)
              (lib.lowPrio neovim)
            ]
            ++ (p.packages or []);

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
  }
