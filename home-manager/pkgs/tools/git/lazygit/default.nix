{
  pkgs,
  repos,
  ...
}: {
  programs.lazygit = {
    enable = true;
    # FIXME(kuriko): use v50 in advance
    package = repos.pkgs-unstable.lazygit;
    # Wait till fromYAML merge: https://github.com/NixOS/nix/pull/7340
    # settings = builtins.fromYAML ./lazygit.yml;
  };

  # NOTE(kuriko): experimentally, try using chezmoi to manage the dotfile
  # home.file.".config/lazygit/config.yml".source = ./config.yml;

  home.shellAliases = {
    lg = "lazygit";
  };
}
