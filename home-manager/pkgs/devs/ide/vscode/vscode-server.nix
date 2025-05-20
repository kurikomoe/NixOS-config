p @ {
  inputs,
  root,
  repos,
  lib,
  ...
}: let
  pkgs = repos.pkgs-unstable;
  deps = pkgs.callPackage ./plugins.nix {inherit pkgs repos;};
in {
  imports = [
    "${inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
    ./plugins-hm.nix
  ];

  services.vscode-server = {
    enableFHS = true;
    enable = true;
    extraRuntimeDependencies = deps.libs;
  };
}
