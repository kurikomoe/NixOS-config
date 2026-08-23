p @ {
  pkgs,
  inputs,
  repos,
  ...
}: let
  inherit (repos) pkgs-unstable;
  PNPM_HOME = "$HOME/.local/opt/pnpm";
in {
  home.packages = with pkgs-unstable; [
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
