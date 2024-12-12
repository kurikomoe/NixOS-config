p @ {
  pkgs,
  inputs,
  repos,
  lib,
  ...
}: let
  combined-pkgs = with pkgs;
  with dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_8_0_3xx
      # sdk_7_0_3xx  # EOL
      sdk_6_0_1xx # EOL
    ];
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
  ];

  home.packages = with pkgs; [
    mono
    # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin
    dotnetPackages.Nuget

    (lib.hiPrio combined-pkgs)
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = lib.mkForce "${combined-pkgs}/share/dotnet";
  };
}
