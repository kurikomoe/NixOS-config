{ config, pkgs, inputs, lib, root, ... }:
let
  PKG_CONFIG_PATH = builtins.foldl' (acc: el: "${acc}:${el}") "" (with pkgs; [
      "${glib.dev}/lib/pkgconfig"
      "${libsoup_3.dev}/lib/pkgconfig"
      "${webkitgtk_4_1.dev}/lib/pkgconfig"
      "${at-spi2-atk.dev}/lib/pkgconfig"
      "${gtk3.dev}/lib/pkgconfig"
      "${gdk-pixbuf.dev}/lib/pkgconfig"
      "${cairo.dev}/lib/pkgconfig"
      "${pango.dev}/lib/pkgconfig"
      "${harfbuzz.dev}/lib/pkgconfig"
      "${zlib.dev}/lib/pkgconfig"
    ]);
in {
  imports = [
    "${root}/packages/libs/openssl.nix"
  ];

  home.packages = with pkgs; [
    # tauri deps
    at-spi2-atk
    atkmm
    cairo
    glib
    gobject-introspection
    gobject-introspection.dev
    gtk3
    harfbuzz
    librsvg
    libsoup_3
    pango
    webkitgtk_4_1
    webkitgtk_4_1.dev
    zlib

    # executable
    cargo-tauri
  ];

  home.sessionVariablesExtra = ''
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${PKG_CONFIG_PATH};
    export LIBRARY_PATH=${pkgs.zlib}/lib;
    export LD_LIBRARY_PATH=${pkgs.zlib}/lib;
  '';
}
