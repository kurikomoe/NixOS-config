p @ {
  pkgs,
  inputs,
  repos,
  lib,
  ...
}: let
  combinedPkgs = with pkgs;
  with dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_8_0_3xx
      # sdk_7_0_3xx  # EOL
      sdk_6_0_1xx # EOL
    ];

  combineMono = pkgs.buildEnv {
    name = "mono-combine";
    paths = with pkgs; [
      mono
      (lib.lowPrio msbuild) # for neovim omnisharp-vim plugin
    ];
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      sdk_9_0 = repos.pkgs-unstable.sdk_9_0;
      sdk_8_0_3xx = repos.pkgs-unstable.sdk_8_0_3xx;
      sdk_6_0_1xx = repos.pkgs-unstable.sdk_6_0_1xx;
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-wrapped-6.0.136"
    "dotnet-sdk-6.0.136"
    "dotnet-sdk-6.0.428"
    "dotnet-runtime-6.0.36"
  ];

  home.packages = with pkgs;
    [
      combineMono
      # mono
      # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin

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
