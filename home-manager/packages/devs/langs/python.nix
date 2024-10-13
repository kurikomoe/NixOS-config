p@{ pkgs, inputs, repos, ... }:

let
  python3 = pkgs.python311;

in {
  # use latest python
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     python3 = pkgs.python311;
  #     python3Packages = pkgs.python311Packages;
  #   })
  # ];


  home.packages = with pkgs; [
    pipx

    (python3.withPackages (py-pkgs: with py-pkgs; [
      pysocks
      requests
      beautifulsoup4
    ]))
  ];
}
