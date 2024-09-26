p@{ root, inputs, pkgs, lib, nixpkgs, ... }:
let
  myShellInit = builtins.readFile ./shell_init.fish;

  # Not appliable on nixos for lacking FHS
  # fish-ssh-agent = pkgs.stdenv.mkDerivation {
  #   pname = "fish-ssh-agent";
  #   version = "unstable";

  #   src = inputs.fish-ssh-agent;

  #   installPhase = ''
  #     echo 233
  #   '';
  # };
in
{
  imports = [
    "${root}/home/devs/common.nix"
    "${root}/home/shells/common.nix"
  ];

  home.packages = with pkgs; [];

  home.shellAliases = {};

  programs = {
    # autojump.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    fish = {
      enable = true;
      shellInit = myShellInit;
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
