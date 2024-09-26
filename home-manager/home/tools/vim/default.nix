{ config, root, pkgs, ... }:
let
  vimPlugins = with pkgs.vimPlugins; [
    ctrlp-vim
    vim-airline
    vim-airline-themes
    vim-sneak
    vim-git
    vim-surround
    nerdcommenter
    nerdtree
    vim-nerdtree-tabs
    vim-nerdtree-syntax-highlight
    vim-devicons
    vim-misc
    vim-better-whitespace
    vim-colorschemes
    awesome-vim-colorschemes
    vim-colors-solarized
    tabular
    vim-easymotion
    undotree
    indentLine
    vim-windowswap
    vim-lastplace
    vim-repeat
    vim-jsbeautify
    vim-polyglot

    coc-go
    coc-sh
    coc-json
    coc-yaml
    coc-toml
    coc-clangd
    coc-cmake
    coc-rust-analyzer
    coc-ultisnips
    coc-java
  ];

  configDir = ".config";
  nvimConfigDir = "${configDir}/nvim";
in {
  imports = [
    "${root}/home/devs/langs/python.nix"
    "${root}/home/devs/langs/ruby.nix"
    "${root}/home/devs/langs/perl.nix"
    "${root}/home/devs/langs/lua.nix"
    "${root}/home/devs/langs/node.nix"
  ];

  xdg.configFile = {
    nvim = {
      source = ./nvim;
      recursive = true;
    };
    vim = {
      source = ./nvim/init.vim;
    };
  };

  home.packages = with pkgs; [
    universal-ctags
    xclip
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = vimPlugins;
  };

  programs.vim = {
    enable = true;
    plugins = vimPlugins;
  };

}
