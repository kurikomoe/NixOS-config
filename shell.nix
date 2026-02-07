{
  pkgs' ? null,
  pkgs-kuriko-nur' ? null,
  pre-commit-hooks' ? null,
  ...
}: let
  pkgs =
    if pkgs' == null
    then import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05") {}
    else pkgs';

  inherit (pkgs) lib fetchFromGitHub;

  pkgs-kuriko-nur =
    if pkgs-kuriko-nur' == null
    then
      import (fetchFromGitHub {
        owner = "kurikomoe";
        repo = "nur-packages";
        rev = "68018133183b99d33bc290cf44d9933abc38f0fc";
        sha256 = "sha256-C+UhZ5BzugS8g/vhzBGrXA0v+7dOlbAoTghveDuWgp4=";
      }) {}
    else pkgs-kuriko-nur';

  pre-commit-hooks =
    if pre-commit-hooks' == null
    then import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master")
    else pre-commit-hooks';

  inherit (pkgs-kuriko-nur) devshell-cache-tools;
in rec {
  pre-commit-check = pre-commit-hooks.run {
    src = ./.;

    hooks = {
      commitizen.enable = true;
      alejandra.enable = true;
      trufflehog = {
        enable = true;
        entry = builtins.toString pkgs-kuriko-nur.precommit-trufflehog;
        stages = ["pre-push" "pre-commit"];
      };
      devshell = {
        enable = true;
        entry = "${devshell-cache-tools}/bin/push-shell";
        stages = ["pre-push"];
        pass_filenames = false;
        always_run = true;
      };
    };
  };

  devShells.default = pkgs.mkShell {
    inherit (pre-commit-check) shellHook;

    packages = with pkgs;
      [
        (lib.hiPrio pkgs-kuriko-nur.devshell-cache-tools)
        (lib.hiPrio pkgs.uutils-findutils)
        (lib.hiPrio pkgs.uutils-diffutils)
        (lib.hiPrio pkgs.uutils-coreutils-noprefix)
      ]
      ++ pre-commit-check.enabledPackages;
  };
}
