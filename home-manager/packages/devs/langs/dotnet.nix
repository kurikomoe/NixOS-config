p@{ pkgs, inputs, repos, lib, ... }:

let
  pkg_dotnet = pkgs.dotnetCorePackages.sdk_9_0;

in {

  home.packages = with pkgs; [
    mono
    # (lib.lowPrio msbuild)  # for neovim omnisharp-vim plugin
    pkg_dotnet
    dotnetPackages.Nuget
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkg_dotnet}";
  };
}
