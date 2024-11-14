p @ {
  pkgs,
  inputs,
  repos,
  lib,
  ...
}: let
  # combined-pkgs = pkgs.symlinkJoin {
  #   name = "dotnet-complete";
  #   paths = with repos.pkgs-unstable; [
  #     dotnetCorePackages.sdk_9_0
  #     dotnetCorePackages.sdk_8_0_3xx
  #     dotnetCorePackages.sdk_7_0_3xx
  #     dotnetCorePackages.sdk_6_0_1xx
  #
  #     # prefer dotnetCorePackages over dotnet-sdk
  #     # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/dotnet.section.md#dotnet-sdk-vs-dotnetcorepackagessdk-dotnet-sdk-vs-dotnetcorepackagessdk
  #     # dotnet-sdk_8
  #     # dotnet-sdk_7
  #     # dotnet-sdk
  #   ];
  # };
  combined-pkgs = with repos.pkgs-unstable;
  with dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_8_0_3xx
      sdk_7_0_3xx
      sdk_6_0_1xx
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
    DOTNET_ROOT = "${combined-pkgs}";
  };
}
