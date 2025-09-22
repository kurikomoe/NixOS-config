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
        rev = "2247608d30c46af719f894e0d5406069d2c8a7aa";
        sha256 = "sha256-C+UhZ5BzugS8g/vhzBGrXA0v+7dOlbAoTghveDuWgp4=";
      }) {}
    else pkgs-kuriko-nur';

  pre-commit-hooks =
    if pre-commit-hooks' == null
    then import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master")
    else pre-commit-hooks';
in rec {
  pre-commit-check = pre-commit-hooks.run {
    src = ./.;

    hooks = {
      alejandra.enable = true;
      trufflehog = {
        enable = true;
        entry = builtins.toString pkgs-kuriko-nur.precommit-trufflehog;
        stages = ["pre-push" "pre-commit"];
      };
    };
  };

  devShells.default = pkgs.mkShell {
    inherit (pre-commit-check) shellHook;

    packages = with pkgs;
      [
        (lib.hiPrio pkgs.uutils-findutils)
        (lib.hiPrio pkgs.uutils-diffutils)
        (lib.hiPrio pkgs.uutils-coreutils-noprefix)
      ]
      ++ pre-commit-check.enabledPackages;
  };
}
