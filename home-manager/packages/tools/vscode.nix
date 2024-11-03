p@{ inputs, pkgs, ... }:

{
  imports = [
    "${inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  home.packages = with pkgs; [
    devcontainer
  ];

  services.vscode-server = {
    enableFHS = false;
    enable = true;
  };
}
