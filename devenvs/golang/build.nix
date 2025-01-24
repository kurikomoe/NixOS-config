{
  config,
  lib,
  pkgs,
  nixpkgs,
  ...
}: let
in rec {
  packages.default = packages."sakura-share";

  packages."sakura-share" = pkgs.buildGoModule {
    pname = "sakura-share";
    version = "0.0.1";

    env = {
      GOPROXY = "https://goproxy.cn";
    };

    src = lib.cleanSource ./.;

    vendorHash = "sha256-5zY4RPt1WS+q3yQICUVJ63F8Nz5S8NyCh9kcYKrjv0w=";
  };
}
