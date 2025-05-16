{
  system,
  inputs,
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
    ];

    settings = rec {
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        https://mirrors.ustc.edu.cn/nix-channels/store
        https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
        # https://mirror.sjtu.edu.cn/nix-channels/store
        https://nix-community.cachix.org
        https://cache.nixos.org

        # vscode-extensions
        https://hydra.iohk.io
      ];
      trusted-substituters = substituters;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

        # vscode-extensions
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
    };
  };

  customNixPkgsImport = pkgSrc: extraConfig:
    import pkgSrc {
      system = system;
      config = _commonNixPkgsConfig;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
      ];
    }
    // extraConfig;

  buildImports = root: xs: (builtins.map (x: "${root}/${x}") xs);
in {
  inherit customNixPkgsImport _commonNixPkgsConfig buildImports;
}
