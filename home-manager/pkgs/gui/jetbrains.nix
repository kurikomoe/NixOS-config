{
  pkgs,
  root,
  ...
}: let
in {
  disabledModules = [
    "programs/jetbrains-remote.nix"
  ];

  imports = [
    "${root.pkgs}/home-manager/jetbrains-remote.nix"
  ];

  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
