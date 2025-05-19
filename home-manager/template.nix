{
  inputs,
  root,
  pkgs,
  customVars,
  repos,
  modules ? [],
  overrideSecrets ? null,
  extraSpecialArgs ? {},
  extraNixPkgsOptions ? {},
  stateVersion ? "24.05",
  ...
} @ p: let
  system = customVars.system;
  lib = pkgs.lib;
  kutils = import "${root.base}/common/kutils.nix" {
    inherit inputs lib;
    enableKCache = true;
  };
in
  with customVars; {
    inherit pkgs;

    extraSpecialArgs =
      {
        inherit customVars inputs root kutils;

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
          imports =
            if overrideSecrets != null
            then overrideSecrets
            else [
              "${root.hm}/pkgs/age.nix"
            ];
        }

        # -------------- enable nur & others overlays ----------------
        {
          # This should be safe, since nur use username as namespace.
          nixpkgs.overlays = [inputs.nur.overlays.default];
          home.packages = [];
        }

        # -------------- nixGL ------------------
        ({
          inputs,
          pkgs,
          system,
          nixpkgs,
          ...
        }: {
          nixpkgs.overlays = [inputs.nixgl.overlays.default];

          nixGL = {
            packages = inputs.nixgl.packages;
            defaultWrapper = "mesa";
          };
        })

        # ------------ user nix settings --------------------
        ({
          config,
          inputs,
          lib,
          ...
        }: {
          imports = [
            "${root.hm-pkgs}/gui/fonts.nix"
            "${root.hm-pkgs}/tools/nixtools.nix"
            "${root.hm-pkgs}/tools/attic/attic-client.nix"
          ];

          home.stateVersion = stateVersion;

          home.username = lib.mkDefault username;
          home.homeDirectory = lib.mkDefault homeDirectory;

          news = {
            display = "show";
          };

          age.secrets.".config/netrc".file = "${root.base}/res/nix/netrc.age";

          nix = {
            package = lib.mkDefault repos.pkgs-unstable.nix;
            gc = lib.mkDefault {
              automatic = true;
              frequency = "weekly";
            };
            settings = lib.recursiveUpdate kutils._commonNixPkgsConfig.settings {
              trusted-users = [username];
              sandbox = true;
              netrc-file = config.age.secrets.".config/netrc".path;
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

              wqy_microhei
              wqy_zenhei

              (lib.lowPrio mkpasswd)

              stdenv.cc.cc.lib

              (lib.lowPrio vim)
              (lib.lowPrio neovim)

              repos.pkgs-unstable.attic-server
              repos.pkgs-unstable.attic-client
            ]
            ++ (p.packages or []);

          home.sessionVariables = {
            EDITOR = lib.mkDefault "nvim";
          };

          programs = lib.mkDefault {
            home-manager.enable = true;

            # ssh = lib.mkDefault {
            #   enable = true;
            #   compression = true;
            #   forwardAgent = true;
            # };

            fish = lib.mkDefault {
              enable = true;
            };
          };

          services.home-manager.autoExpire = lib.mkDefault {
            enable = true;
            frequency = "weekly";
            timestamp = "-14 days";
          };
        })
      ];
  }
