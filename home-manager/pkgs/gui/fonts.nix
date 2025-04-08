{
  pkgs,
  lib,
  repos,
  ...
}: let
in {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    sarasa-gothic

    wqy_zenhei
    wqy_microhei

    repos.pkgs-kuriko-nur.kfonts

    jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
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
