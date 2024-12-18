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
      ./age.nix
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
          ++ [];

        home.packages = with pkgs; [];

        services.podman = {
          enable = true;
        };
      })
    ];
  });
in
  hm-template
