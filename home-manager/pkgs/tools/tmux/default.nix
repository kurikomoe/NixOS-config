p @ {
  lib,
  inputs,
  pkgs,
  ...
}: let
  tmuxExtraConfig = builtins.readFile ./tmux.conf;

  tmux-themepack = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "themepack";
    version = "unstable-2024-09-24";
    src = ./tmux-themepack;
  };

  tmux-current-pane-hostname = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "current-pane-hostname";
    version = "unstable";
    src = inputs.tmux-current-pane-hostname;
  };
in {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    newSession = true;
    aggressiveResize = true;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 9999;
    mouse = true;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      # tmux-themepack
      # nord
      tmux-current-pane-hostname
      yank
      sessionist
      pain-control
      resurrect
      battery
      sensible
      better-mouse-mode
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'true'
        '';
      }
      {
        plugin = prefix-highlight;
        extraConfig = ''
          set -g @prefix_highlight_fg 'red'   # default is 'colour231'
          set -g @prefix_highlight_bg 'blue'  # default is 'colour04'

          set -g @prefix_highlight_output_prefix ""
          set -g @prefix_highlight_output_suffix ""

          # 设置项目
          set -g status-left-length 100

          set -g status-right-length 100
          # set -g status-right '#{prefix_highlight}| %a %h-%d %H:%M '
          set -g status-right '#{prefix_highlight}| #(whoami)@#H | %a %h-%d %H:%M '
        '';
      }
    ];
    extraConfig = tmuxExtraConfig;
  };
}
