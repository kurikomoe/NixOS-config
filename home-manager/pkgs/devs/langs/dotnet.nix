p @ {
  pkgs,
  inputs,
  repos,
  lib,
  ...
}: let
  combined-pkgs = pkgs.symlinkJoin {
    name = "dotnet-complete";
    paths = with pkgs; [
      dotnet-sdk_8
      dotnet-sdk_7
      dotnet-sdk
    ];
  };
in {
  home.packages = with pkgs; [
    mono
    # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin

    combined-pkgs

    dotnetPackages.Nuget
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${combined-pkgs}";
  };
}
