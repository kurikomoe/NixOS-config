p @ {
  inputs,
  pkgs,
  root,
  repos,
  lib,
  ...
}: let
  pluginList = pkgs.callPackage ./plugins.nix {pkgs = repos.pkgs-unstable;};
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
