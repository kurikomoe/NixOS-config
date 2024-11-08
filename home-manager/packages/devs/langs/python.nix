p@{ pkgs, inputs, repos, ... }:

let
  python3 = pkgs.python312;

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

    pylint

    (python3.withPackages (py-pkgs: with py-pkgs; [
      pexpect

      xlsxwriter
      python-docx
      pyyaml

      pytz
      more-itertools

      coloredlogs

      pillow
      pandas
      numpy
      seaborn
      matplotlib
      scipy
      tqdm

      pydantic

      pysocks
      aiohttp
      fastapi
      hypercorn
      uvicorn
      requests
      beautifulsoup4
    ]))
  ];
}
