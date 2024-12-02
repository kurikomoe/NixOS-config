p @ {
  pkgs,
  inputs,
  repos,
  lib,
  ...
}: let
  combined-pkgs = with repos.pkgs-unstable;
  with dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_8_0_3xx
      # sdk_7_0_3xx  # EOL
      # sdk_6_0_1xx  # EOL
      # dotnet-runtime_7
      dotnet-runtime
    ];
in {
  home.packages = with pkgs; [
    mono
    # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin

    (lib.hiPrio combined-pkgs)

    dotnetPackages.Nuget
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = lib.mkForce "${combined-pkgs}/share/dotnet";
  };
}
