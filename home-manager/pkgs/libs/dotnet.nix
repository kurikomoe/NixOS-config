{
  pkgs,
  lib,
  ...
}: let
  combined-pkgs = pkgs.symlinkJoin {
    name = "dotnet-runtime-complete";
    paths = with pkgs; [
      dotnet-runtime_8
      dotnet-runtime_7
      dotnet-runtime
    ];
  };
in {
  home.packages = with pkgs; [
    (lib.loPrio combined-pkgs)
  ];

  home.sessionVariables = {
    DOTNET_RUNTIME_ROOT = "${combined-pkgs}";
  };
}
