{
  config,
  pkgs,
  lib,
  ...
}: let
  # PKG_CONFIG_PATH = "$PKG_CONFIG_PATH\${PKG_CONFIG_PATH:+:}${pkgs.openssl.dev}/lib/pkgconfig";
in {
  home.packages = with pkgs; [
    openssl
    pkg-config
  ];

  home.sessionVariablesExtra = ''
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${pkgs.openssl.dev}/lib/pkgconfig;
  '';
}
