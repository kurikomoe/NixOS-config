{
  repos,
  root,
  ...
}: let
  pkgs = repos.pkgs-unstable;

  push-cache = pkgs.writeShellScriptBin "push-cache" ''
    ${pkgs.attic-client}/bin/attic push r2 $@
  '';
  push-cache-hm = pkgs.writeShellScriptBin "push-cache-hm" ''
    ${push-cache}/bin/push-cache \
      $(realpath ~/.local/state/nix/profiles/home-manager) $@
  '';
  push-cache-nixos = pkgs.writeShellScriptBin "push-cache-nixos" ''
    ${push-cache}/bin/push-cache \
      $(realpath /nix/var/nix/profiles/system) $@
  '';
in {
  home.packages = with pkgs; [
    push-cache
    push-cache-hm
    push-cache-nixos
    attic-client
  ];

  # setup cache
  age.secrets.".config/attic/config.toml" = {
    file = "${root.base}/res/attic/config.toml.age";
    path = ".config/attic/config.toml";
  };
}
