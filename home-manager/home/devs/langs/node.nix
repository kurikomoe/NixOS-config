p@{ pkgs, inputs, ... }:

let

in {
  home.packages = with pkgs; [
    nodejs_22
    bun
    deno

    pnpm
    yarn
  ];
}
