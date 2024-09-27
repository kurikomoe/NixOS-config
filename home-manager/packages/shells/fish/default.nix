p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let
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

    fish = {
      enable = true;
      shellInit = ''
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
