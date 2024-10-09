p@{ pkgs, inputs, repos, ... }:

let
  pkg_dotnet = pkgs.dotnet-sdk_8;

in {

  home.packages = with pkgs; [
    mono
    pkg_dotnet
    dotnetPackages.Nuget
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkg_dotnet}";
  };
}
