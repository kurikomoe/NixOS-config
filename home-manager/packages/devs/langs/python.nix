p@{ pkgs, inputs, repos, ... }:

let

in {
  # use latest python
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     python3 = repos.pkgs-unstable.python3;
  #   })
  # ];

  home.packages = with pkgs; [
    pipx

    python312

    python312Packages.pysocks
  ];
}