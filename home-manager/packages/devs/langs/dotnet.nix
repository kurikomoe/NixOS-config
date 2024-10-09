p@{ pkgs, inputs, repos, lib, ... }:

let
  pkg_dotnet = pkgs.dotnet-sdk_8;

in {

  home.packages = with pkgs; [
    mono
    # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin
    pkg_dotnet
    dotnetPackages.Nuget
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkg_dotnet}";
  };
}
