{
  pkgs,
  lib,
  repos,
  ...
}: let
in rec {
  _module.args.fonts = with pkgs; [
    inconsolata

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    source-serif-pro
    source-han-serif

    sarasa-gothic

    wqy_zenhei
    wqy_microhei

    # repos.pkgs-unstable.maple-mono.CN
    _0xproto

    repos.pkgs-kuriko-nur.kfonts
    repos.pkgs-kuriko-nur.kuriko-all-fonts

    jetbrains-mono

    ibm-plex
  ];

  home.packages = _module.args.fonts;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Maple Mono CN"
        "0xProto"
        "JetBrains Mono"
        "Sarasa Mono SC"
        "Noto Sans Mono CJK SC"
      ];
      sansSerif = [
        "Sarasa UI SC"
        "更纱黑体 UI SC"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Sarasa UI SC"
        "更纱黑体 UI SC"
        "Noto Serif CJK SC"
      ];
    };
  };
}
