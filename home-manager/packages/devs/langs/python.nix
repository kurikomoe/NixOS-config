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
    python312

    poetry

    python312Packages.pysocks
  ];
}
