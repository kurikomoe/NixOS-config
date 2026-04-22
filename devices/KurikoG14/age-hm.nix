{
  config,
  inputs,
  customVars,
  lib,
  root,
  pkgs,
  kutils,
  ...
}: let
  home = config.home.homeDirectory;
  agenixPkg = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" {};

  identityPaths = [
    "${home}/.ssh/id_ed25519_age"
  ];

  helper = kutils.age.agehelper;

  age_secrets_filelist =
    {}
    // (helper "opencode/config/opencode.jsonc" "${home}/.config/opencode/opencode.jsonc")
    // (helper "opencode/config/tui.jsonc" "${home}/.config/opencode/tui.jsonc");
in {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    agenixPkg
  ];

  age = {
    inherit identityPaths;
    secretsDir = "${home}/.agenix";
    secrets = age_secrets_filelist;
  };

  # https://github.com/ryantm/agenix/issues/50#issuecomment-1926893522
  # home.activation.agenix = lib.hm.dag.entryAnywhere config.systemd.user.services.agenix.Service.ExecStart;
}
