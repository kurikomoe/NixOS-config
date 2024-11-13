{
  pkgs,
  lib,
  ...
}: let
  # combined-runtime-pkgs = pkgs.symlinkJoin {
  #   name = "dotnet-runtime-complete";
  #   paths = with pkgs; [
  #     dotnet-runtime_8
  #     dotnet-runtime_7
  #     dotnet-runtime
  #   ];
  # };

  combined-runtime-pkgs =
    with pkgs;
    with dotnetCorePackages; combinePackages [
      dotnet_9.runtime
      dotnet_8.runtime
      dotnet-runtime_7
      dotnet-runtime
    ];
in {
  home.packages = with pkgs; [
    (lib.loPrio combined-runtime-pkgs)
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${combined-runtime-pkgs}";
  };
}
