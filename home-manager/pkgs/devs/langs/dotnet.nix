p @ {
  pkgs,
  inputs,
  repos,
  lib,
  useGlobalPkgs,
  ...
}: let
  combinedPkgs = with repos.pkgs-stable;
  with dotnetCorePackages;
    combinePackages [
      sdk_10_0-bin
      sdk_9_0-bin
      sdk_8_0-bin
    ];
in {
  nixpkgs = lib.mkIf (!useGlobalPkgs) {
    overlays = with repos.pkgs-stable.dotnetCorePackages; [
      (final: prev: {
        inherit (repos.pkgs-stable) dotnet-sdk_10_0-bin sdk_9_0_3xx-bin sdk_8_0_3xx-bin sdk_6_0_1xx-bin;
      })
    ];

    config.permittedInsecurePackages = [
      "dotnet-sdk-wrapped-6.0.136"
      "dotnet-sdk-6.0.136"
      "dotnet-sdk-6.0.428"
      "dotnet-runtime-6.0.36"
    ];
  };

  home.packages = with pkgs;
    [
      mono

      dotnetPackages.Nuget

      (lib.hiPrio combinedPkgs)
    ]
    ++ (with repos.pkgs-kuriko-nur; [
      dotnet-script
    ]);

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = lib.mkForce "${combinedPkgs}/share/dotnet";
  };
}
