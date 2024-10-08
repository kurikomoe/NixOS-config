p@{ pkgs, inputs, repos, ... }:

let

in {
  # use latest python
  nixpkgs.overlays = [
    (final: prev: {
      # python3 = repos.pkgs-unstable.python312.override {
      #   enableGIL = false;
      # };
      python3 = repos.pkgs-unstable.python3;
    })
  ];

  home.packages = with pkgs; [
    pipx
    python3
  ];
}
