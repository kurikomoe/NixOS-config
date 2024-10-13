p@{ pkgs, inputs, repos, ... }:

let

in {
  # use latest python
  nixpkgs.overlays = [
    (final: prev: {
      python3 = pkgs.python311;
      python3Packages = pkgs.python311Packages;
    })
  ];

  home.packages = with pkgs; [
    pipx

    python3

    # common used packages to avoid creating nix-shell for small projs
    python3Packages.pysocks
    python3Packages.requests
    python3Packages.beautifulsoup4
  ];
}
