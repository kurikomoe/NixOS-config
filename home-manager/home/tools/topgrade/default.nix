{ pkgs, inputs, config, ... }:

{
  home.file."${config.xdg.configHome}/topgrade.toml".source = ./topgrade.toml;

  home.shellAliases = {
    up = "topgrade";
  };

  programs.topgrade = {
    enable = true;
  };
}
