p @ {
  pkgs,
  inputs,
  lib,
  repos,
  ...
}: let
in {
  imports = [
    ./c_cpp.nix
    ./zig.nix
  ];

  # use fenix rust overlay
  nixpkgs.overlays = [inputs.fenix.overlays.default];

  home.packages = with pkgs; [
    rustup
    repos.pkgs-unstable.bacon
  ];

  home.sessionPath = lib.mkBefore [
    "$HOME/.cargo/bin"
  ];

  home.activation.rustInit = lib.hm.dag.entryAfter ["installPackages"] ''
    run ${pkgs.rustup}/bin/rustup install stable nightly;
  '';
}
# --------- code snippets -------------
# fenix should be used in side projects to keep the toolchains versioned
# (fenix.complete.withComponents [
#   "cargo"
#   "clippy"
#   "rust-src"
#   "rustc"
#   "rustfmt"
# ])

