{
  inputs,
  lib,
  enableKCache ? false,
  ...
}: let
  _commonNixPkgsConfig = {
    allowUnfree = true;

    # allow test fails
    doCheck = false;
    checkPhase = "true";
    allowBroken = true;

    permittedInsecurePackages = [
      "dotnet-runtime-7.0.20"
      "dotnet-sdk-wrapped-6.0.136"
      "dotnet-sdk-6.0.136"
      "dotnet-sdk-6.0.428"
      "dotnet-runtime-6.0.36"
    ];

    settings = rec {
      experimental-features = ["nix-command" "flakes"];
      substituters =
        [
          "https://cache.nixos.org"
          "https://nixpkgs-python.cachix.org"
          "https://nix-community.cachix.org"

          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

          "https://kurikomoe.cachix.org"
          # "https://hydra.iohk.io # vscode-extensions"
        ]
        ++ lib.concatLists [
          (lib.optional enableKCache "https://nix-cache.0v0.io/r2")
        ];
      trusted-substituters = substituters;
      trusted-public-keys =
        [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="

          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

          "kurikomoe.cachix.org-1:NewppX3NeGxT8OwdwABq+Av7gjOum55dTAG9oG7YeEI="

          # "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        ]
        ++ lib.concatLists [
          (lib.optional enableKCache "r2:p04JD2QTSWn937oqqCMX9CdMAd71ulb1FZZm+3Nd/9c=")
        ];
    };
  };

  customNixPkgsImport = system: pkgSrc: extraConfig: let
    finalConfig =
      lib.recursiveUpdate {
        inherit system;
        config = _commonNixPkgsConfig;
        overlays = [
          inputs.nix-vscode-extensions.overlays.default
        ];
      }
      extraConfig;
  in
    import pkgSrc finalConfig;

  buildImports = root: xs: (builtins.map (x: "${root}/${x}") xs);

  buildPath = {
    srcPath,
    dstPath,
  }: let
    traverse = path: prefix: let
      entries = builtins.readDir path;
      processEntry = name: let
        fullPath = "${path}/${name}";
      in
        if entries.${name}.isDir
        then traverse fullPath (prefix + "/" + name)
        else {
          inherit (lib) mkMerge;
          home.file."${prefix}/${name}".source = fullPath;
        };
    in
      lib.concatMapAttrs processEntry entries;
  in
    traverse srcPath dstPath;
in {
  inherit customNixPkgsImport _commonNixPkgsConfig buildImports buildPath;
}
