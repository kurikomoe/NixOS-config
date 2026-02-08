{
  pkgs ? "<nixpkgs>",
  pkgs-kuriko-nur ? null,
  pre-commit-hooks ? null,
  ...
} @ inputs: let
  pkgs = inputs.pkgs;

  inherit (pkgs) lib fetchFromGitHub;

  pkgs-kuriko-nur =
    inputs.pkgs-kuriko-nur  or (import (fetchFromGitHub {
      owner = "kurikomoe";
      repo = "nur-packages";
      rev = "main";
      sha256 = "sha256-C+UhZ5BzugS8g/vhzBGrXA0v+7dOlbAoTghveDuWgp4=";
    }) {});

  pre-commit-hooks = inputs.pre-commit-hooks or (import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master"));

  inherit (pkgs-kuriko-nur) devshell-cache-tools precommit-trufflehog;
in rec {
  pre-commit-check = pre-commit-hooks.run {
    src = ./.;

    hooks = {
      commitizen.enable = true;
      alejandra.enable = true;
      trufflehog = {
        enable = true;
        entry = "${precommit-trufflehog}/bin/precommit-trufflehog";
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
