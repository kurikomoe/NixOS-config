p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let
  fish-command-timer = pkgs.fishPlugins.buildFishPlugin {
    pname = "fish-command-timer";
    version = "unstable";
    src = inputs.fish-command-timer;
  };

  myShellInit = builtins.readFile ./shell_init.fish;
in
{
  imports = [
    "${root}/packages/devs/common.nix"
    "${root}/packages/shells/common.nix"
  ];

  home.packages = with pkgs; [];

  home.shellAliases = {};

  programs = {
    # autojump.enable = true;
    dircolors.enableFishIntegration = true;

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
      shellInit = ''
        # in milliseconds
        set fish_command_timer_min_cmd_duration 15000;
        source ${fish-command-timer.src}/fish_command_timer.fish;

        # set fish_prompt_pwd_dir_length 0

        # function postexec_test --on-event fish_postexec
        #    echo
        # end
      '';
      plugins = with pkgs.fishPlugins; [
        # {
        #   name = "fish-ssh-agent";
        #   src = fish-ssh-agent.src;
        # }
        {
          name = "async-prompt";
          src = async-prompt.src;
        }
        {
          name = "sponge";
          src = sponge.src;
        }
        # {
        #   name = "pure";
        #   src = pure.src;
        # }
        {
          name = "humantime-fish";
          src = humantime-fish.src;
        }
        # {
        #   name = "git-abbr";
        #   src = git-abbr.src;
        # }
      ];
    };

  };
}
