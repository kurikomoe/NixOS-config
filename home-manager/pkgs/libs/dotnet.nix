{
  pkgs,
  lib,
  ...
}: let
  combined-runtime-pkgs = with pkgs;
  with dotnetCorePackages;
    combinePackages [
      dotnet_9.runtime
      dotnet_8.runtime
      # dotnet-runtime_7
      dotnet-runtime
    ];
in {
  home.packages = with pkgs; [
    # (lib.lowPrio combined-runtime-pkgs)
  ];

  home.sessionVariables = {
    # DOTNET_ROOT = lib.mkDefault "${combined-runtime-pkgs}/share/dotnet";
  };
}
