p @ {
  root,
  inputs,
  pkgs,
  lib,
  nixpkgs,
  ...
}: let
  fish-command-timer = pkgs.fishPlugins.buildFishPlugin {
    pname = "fish-command-timer";
    version = "unstable";
    src = inputs.fishPlugin-fish-command-timer;
  };

  replay = pkgs.fishPlugins.buildFishPlugin {
    pname = "replay";
    version = "unstable";
    src = inputs.fishPlugin-replay;
  };

  fish-ssh-agent = pkgs.fishPlugins.buildFishPlugin {
    pname = "fish-ssh-agent";
    version = "unstable";
    src = inputs.fishPlugin-fish-ssh-agent;
  };

  autopair = pkgs.fishPlugins.buildFishPlugin {
    pname = "autopair";
    version = "unstable";
    src = inputs.fishPlugin-autopair;
  };

  puffer-fish = pkgs.fishPlugins.buildFishPlugin {
    pname = "puffer-fish";
    version = "unstable";
    src = inputs.fishPlugin-puffer-fish;
  };

  fish-abbreviation-tips = pkgs.fishPlugins.buildFishPlugin {
    pname = "fish-abbreviation-tips";
    version = "unstable";
    src = inputs.fishPlugin-fish-abbreviation-tips;
  };

  theme-dracula = pkgs.fishPlugins.buildFishPlugin {
    pname = "theme-dracula";
    version = "unstable";
    src = inputs.fishPlugin-theme-dracula;
  };

  shellInit = ''
    set fish_command_timer_min_cmd_duration 15000; # in milliseconds
    source ${fish-command-timer.src}/fish_command_timer.fish;
  '';

  myInteractiveShellInit = builtins.readFile ./shell_init.fish;
  interactiveShellInit = ''
    ${myInteractiveShellInit}
    ${builtins.readFile ./venv.fish}
  '';
in {
  imports = [
    "${root.hm-pkgs}/devs/common.nix"
    "${root.hm-pkgs}/shells/common.nix"
  ];

  home.packages = with pkgs; [];

  home.shellAliases = {};

  programs = {
    dircolors.enableFishIntegration = true;
    atuin.enableFishIntegration = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    autojump = {
      enable = true;
      enableFishIntegration = true;
    };

    fish = {
      enable = true;
      inherit shellInit interactiveShellInit;
      functions = {
        # "auto_enter_venv" = {
        #   body = ''
        #     status --is-command-substitution; and return
        #
        #     # Check if we are inside a git directory
        #     if git rev-parse --show-toplevel &>/dev/null
        #       set gitdir (realpath (git rev-parse --show-toplevel))
        #       set cwd (pwd -P)
        #       # While we are still inside the git directory, find the closest
        #       # virtualenv starting from the current directory.
        #       while string match "$gitdir*" "$cwd" &>/dev/null
        #         if test -e "$cwd/.venv/bin/activate.fish"
        #           source "$cwd/.venv/bin/activate.fish" &>/dev/null
        #           return
        #         else
        #           set cwd (path dirname "$cwd")
        #         end
        #       end
        #     end
        #     # If virtualenv activated but we are not in a git directory, deactivate.
        #     if test -n "$VIRTUAL_ENV"
        #       deactivate
        #     end
        #   '';
        #   onVariable = "PWD";
        # };
        # "auto_enter_direnv" = {
        #   body = ''
        #     set -l nix_shell_info (
        #       if test -n "$IN_NIX_SHELL"
        #         echo -n "<nix-shell> "
        #       end
        #     )
        #   '';
        #   onVariable = "PWD";
        # };
      };
      plugins = with pkgs.fishPlugins; [
        {
          name = "fish-abbreviation-tips";
          src = fish-abbreviation-tips.src;
        }
        {
          name = "puffer-fish";
          src = puffer-fish.src;
        }
        {
          name = "autopair";
          src = autopair.src;
        }
        {
          name = "replay";
          src = replay.src;
        }
        {
          name = "fish-ssh-agent";
          src = fish-ssh-agent.src;
        }
        {
          name = "async-prompt";
          src = async-prompt.src;
        }
        {
          name = "humantime-fish";
          src = humantime-fish.src;
        }

        # disable this since it grep out failed commands
        # { name = "sponge"; src = sponge.src; }

        # { name = "pure"; src = pure.src; }
        # { name = "git-abbr"; src = git-abbr.src; }

        {
          name = "theme-dracula";
          src = theme-dracula.src;
        }
      ];
    };
  };
}
