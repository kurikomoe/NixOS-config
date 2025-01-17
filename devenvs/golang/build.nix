{
  config,
  lib,
  pkgs,
  nixpkgs,
  ...
}: let
in {
  packages.default = pkgs.buildGoModule {
    pname = "sakura-share";
    version = "0.0.1";

    vendorHash = null;

    src = ./.;
  };
}
