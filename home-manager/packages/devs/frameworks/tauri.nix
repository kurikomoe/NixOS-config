{ pkgs, inputs, lib, ... }:
let

in {
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

    # executable
    cargo-tauri
  ];

  home.sessionVariables = with pkgs; {
    PKG_CONFIG_PATH = "${glib.dev}/lib/pkgconfig:${libsoup_3.dev}/lib/pkgconfig:${webkitgtk_4_1.dev}/lib/pkgconfig:${at-spi2-atk.dev}/lib/pkgconfig:${gtk3.dev}/lib/pkgconfig:${gdk-pixbuf.dev}/lib/pkgconfig:${cairo.dev}/lib/pkgconfig:${pango.dev}/lib/pkgconfig:${harfbuzz.dev}/lib/pkgconfig";
  };
}
