p@{ pkgs, inputs, lib, ... }:

let

in {
  imports = [
    ./c_cpp.nix
    ./zig.nix
  ];

  home.packages = with pkgs; [
    rustup
  ];

  home.sessionPath = lib.mkBefore [
    "$HOME/.cargo/bin"
  ];
}
