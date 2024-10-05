p@{ pkgs, inputs, lib, repos, ... }:

let

in {
  imports = [
    ./c_cpp.nix
    ./zig.nix
  ];

  home.packages = with pkgs; [
    rustup
    repos.pkgs-unstable.bacon
  ];

  home.sessionPath = lib.mkBefore [
    "$HOME/.cargo/bin"
  ];
}
