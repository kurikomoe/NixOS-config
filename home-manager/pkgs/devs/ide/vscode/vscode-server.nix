p @ {
  inputs,
  root,
  repos,
  lib,
  ...
}: let
  pkgs = repos.pkgs-unstable;
  pluginList = pkgs.callPackage ./plugins.nix {inherit pkgs;};
in {
  imports = [
    "${inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  home.packages = pluginList;

  services.vscode-server = {
    enableFHS = false;
    enable = true;
  };
}
