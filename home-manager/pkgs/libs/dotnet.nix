{
  pkgs,
  lib,
  ...
}: let
  # combined-runtime-pkgs = with pkgs;
  # with dotnetCorePackages;
  #   combinePackages [
  #     dotnet_9.runtime
  #     dotnet_8.runtime
  #     # dotnet-runtime_7
  #     dotnet-runtime
  #   ];
  combinedDotnetRuntimes = pkgs.symlinkJoin {
    name = "dotnet-runtimes";
    paths = with pkgs;
    with dotnetCorePackages; [
      dotnet-runtime_9
      dotnet-runtime # 8 at current time
      dotnet-runtime_6
    ];
    symlinkJoinBuildInputs = [
      # Avoid conflicts by preferring the first occurrence of each file
      "--resolve-conflicts=preferLeft"
    ];
  };
in {
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-wrapped-6.0.36"
    "dotnet-runtime-6.0.36"
    "dotnet-sdk-wrapped-6.0.136"
    "dotnet-sdk-6.0.136"
  ];

  home.packages = with pkgs;
  with dotnetCorePackages; [
    # combined-runtime-pkgs
    combinedDotnetRuntimes
  ];

  home.sessionVariables = {
    DOTNET_ROOT = lib.mkDefault "${combinedDotnetRuntimes}/share/dotnet";
  };
}
