p@{ pkgs, inputs, ... }:

let
  PNPM_HOME = "$HOME/.local/opt/pnpm";
in {
  home.packages = with pkgs; [
    nodejs_22
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
