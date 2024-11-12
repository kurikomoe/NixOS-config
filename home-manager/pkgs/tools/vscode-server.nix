p @ {
  inputs,
  pkgs,
  root,
  ...
}: {
  imports = [
    "${inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  home.packages = with pkgs; [
    # wait for fix
    # devcontainer
    (pkgs.callPackage "${root.pkgs}/devcontainer.nix" {})
  ];

  services.vscode-server = {
    # enableFHS = false;
    enable = true;
  };
}
