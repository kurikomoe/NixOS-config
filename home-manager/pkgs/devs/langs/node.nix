p @ {
  pkgs,
  inputs,
  repos,
  ...
}: let
  inherit (repos) pkgs-unstable;
  PNPM_HOME = "$HOME/.local/opt/pnpm";
in {
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (pkgs-unstable)
        bun
        deno
        nodejs
        pnpm
        yarn
        ;
      pnpm_8 = pkgs-unstable.pnpm;
    })
  ];

  home.packages = with pkgs; [
    nodejs
    deno

    bun

    yarn
    pnpm
  ];

  home = {
    sessionVariables = {
      inherit PNPM_HOME;
    };
    sessionPath = [
      "${PNPM_HOME}"
    ];
  };
}
