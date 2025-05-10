{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  utils = import "${root.base}/common/utils.nix" {inherit system;};

  hm-template = import "${root.hm}/template.nix" (with customVars; {
    inherit inputs root customVars repos pkgs;

    overrideSecrets = [
      ./age-hm.nix
    ];

    stateVersion = "24.11";

    extraNixPkgsOptions = {};

    extraSpecialArgs = {};

    modules = [
      ({pkgs, ...}: {
        imports =
          utils.buildImports root.hm-pkgs [
            "./shells/fish"

            "./tools/ssh/tx-cloud.nix"

            # "./devs/common.nix"
            # "./devs/langs"

            # "./tools"

            # "./libs/others.nix"

            # "./libs/dotnet.nix"

            # "./libs/cuda.nix"

            # "./apps/db/mongodb.nix"
            # "./apps/db/mariadb.nix"

            # "./gui/fonts.nix"
            # "./gui/browsers"
            # "./gui/jetbrains.nix"

            # "./apps/podman.nix"
          ]
          ++ [
            "${root.base}/home-manager/pkgs/devs/langs/python.nix"
            "${root.base}/home-manager/pkgs/devs/langs/c_cpp.nix"
            "${root.base}/home-manager/pkgs/devs/langs/node.nix"
            "${root.base}/home-manager/pkgs/devs/common.nix"
            "${root.base}/home-manager/pkgs/devs/tools.nix"
            "${root.base}/home-manager/pkgs/tools/tmux"
            "${root.base}/home-manager/pkgs/tools/others.nix"
            "${root.base}/home-manager/pkgs/tools/vim"
            "${root.base}/home-manager/pkgs/tools/vscode-server.nix"
          ];

        home.packages = with pkgs; [
          teamspeak_server
        ];

        age.secrets."docker/config.json".path = ".docker/config.json";

        services.podman = {
          enable = true;
        };
      })
    ];
  });
in
  hm-template
