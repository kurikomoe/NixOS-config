{
  config,
  inputs,
  root,
  pkgs,
  lib,
  ...
}: let
  home = config.home.homeDirectory;
  xdg_config = config.xdg.configHome;

  identityPaths = [
    "${home}/.ssh/id_ed25519"
    "${home}/.ssh/id_ed25519_age"
  ];

  secret_file = filepath: {
    "${filepath}".file = "${root.base}/res/${filepath}.age";
  };

  agenix-edit = pkgs.writeShellScriptBin "agenix-edit" "agenix  -e $@";
in {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    agenix-edit
    inputs.agenix.packages.${system}.default
  ];

  age = {
    inherit identityPaths;

    secretsDir = "${home}/.agenix";

    secrets =
      {}
      # ----------------------------------------------------------
      # // secret_file "gnupg/private.pgp"
      # // secret_file "gnupg/public.pgp"
      # ----------------------------------------------------------
      # // secret_file "ssh/config"
      # // secret_file "ssh/config-iprc"
      # // secret_file "ssh/id_rsa"
      # // secret_file "ssh/id_rsa.pub"
      # // secret_file "ssh/id_ed25519"
      # // secret_file "ssh/id_ed25519.pub"
      # // secret_file "ssh/id_ed25519_age.pub"
      # ----------------------------------------------------------
      // secret_file "docker/config.json"
      # ----------------------------------------------------------
      // secret_file "gh/hosts.yml"
      # ----------------------------------------------------------
      // secret_file "nix/access-tokens"
      // secret_file "nix/cachix.nix.conf";
  };

  # https://github.com/ryantm/agenix/issues/50#issuecomment-1926893522
  home.activation.agenix = lib.hm.dag.entryAnywhere config.systemd.user.services.agenix.Service.ExecStart;
}
