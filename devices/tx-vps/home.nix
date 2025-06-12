{
  inputs,
  pkgs,
  root,
  customVars,
  repos,
  ...
}: let
  system = customVars.system;
  lib = pkgs.lib;
  kutils = import "${root.base}/common/kutils.nix" {inherit inputs lib;};

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
          kutils.buildImports root.hm-pkgs [
            "./shells/fish"

            "./tools/ssh/tx-cloud.nix"

            # "./devs/common.nix"
            # "./devs/langs"
            "./devs/langs/golang.nix"

            # "./tools"

            # "./libs/others.nix"

            # "./libs/dotnet.nix"

            # "./libs/cuda.nix"

            # "./apps/db/mongodb.nix"
            # "./apps/db/mariadb.nix"

            # "./gui/fonts.nix"
            # "./gui/browsers"
            # "./gui/jetbrains.nix"

            "./apps/podman.nix"
          ]
          ++ [
            "${root.hm-pkgs}/devs/ide/vscode/vscode-server.nix"
            "${root.hm-pkgs}/devs/langs/python.nix"
            "${root.hm-pkgs}/devs/langs/c_cpp.nix"
            "${root.hm-pkgs}/devs/langs/node.nix"
            "${root.hm-pkgs}/devs/common.nix"
            "${root.hm-pkgs}/devs/tools.nix"
            "${root.hm-pkgs}/tools/tmux"
            "${root.hm-pkgs}/tools/others.nix"
            "${root.hm-pkgs}/tools/vim"
          ];

        home.packages = with pkgs; [
          teamspeak_server
          rustdesk-server
        ];

        age.secrets."docker/config.json".path = ".docker/config.json";
      })
    ];
  });
in
  hm-template
