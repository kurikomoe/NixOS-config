{
  inputs,
  root,
  pkgs,
  ...
}: let
  # omnisharp-vim-plugin = pkgs.vimUtils.buildVimPlugin {
  #   name = "omnisharp-vim";
  #   src = inputs.omnisharp-vim;
  # };
  zig-vim = pkgs.vimUtils.buildVimPlugin {
    name = "zig-vim";
    src = inputs.zig-vim;
  };

  coc-zig-plugin = pkgs.vimUtils.buildVimPlugin {
    name = "coc-zig";
    src = inputs.coc-zig;
  };

  vimPlugins = with pkgs.vimPlugins; [
    coc-nvim
    nvim-lspconfig

    coc-zig-plugin
    zig-vim

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
    # vim-polyglot

    # not working for now
    # omnisharp-vim-plugin

    csharpls-extended-lsp-nvim

    # coc-ultisnips
    coc-highlight
    coc-yank
    coc-prettier
    coc-fzf

    coc-json
    coc-yaml
    coc-toml

    # coc-tabnine
    # coc-cmake
    coc-git

    # coc-go # deprecated
    coc-sh
    coc-clangd
    coc-rust-analyzer
    # coc-java
    coc-lua
    coc-css
    coc-html
    coc-pairs
    coc-pyright
  ];
in {
  nixpkgs.overlays = [
    (final: prev: {
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  # neovim deps
  imports = [
    "${root.hm-pkgs}/devs/langs/python.nix"
    "${root.hm-pkgs}/devs/langs/ruby.nix"
    "${root.hm-pkgs}/devs/langs/perl.nix"
    "${root.hm-pkgs}/devs/langs/lua.nix"
    "${root.hm-pkgs}/devs/langs/node.nix"
  ];

  # Legacy vimrc
  home.file.".confvim/vimrc".source = ./nvim/init.vim;

  home.packages = with pkgs; [
    universal-ctags
    xclip # Clipboard support

    # csharp-ls

    # vim alternative?
    helix
  ];

  # for omnisharp-vim to find the executable
  home.sessionPath = [
    "$HOME/.cache/omnisharp-vim/omnisharp-roslyn"
  ];

  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    # Lazy owns Neovim plugins; the Nix plugin list is only for legacy Vim.
    initLua = builtins.readFile ./nvim/init.lua;
    extraPackages = with pkgs; [
      git
      curl
      wget
      unzip
      gnutar
      gzip
      xz
      gcc
      gnumake
      nodejs
      go # Mason builds gopls, goimports and gofumpt with Go.
      rustfmt # Fallback when no project/rustup formatter is on PATH.
      zig # zig fmt is part of the Zig toolchain, not a Mason package.
      (python3.withPackages (ps: [ps.pip]))
      ripgrep
      fd
      tree-sitter
    ];
  };

  xdg.configFile = {
    "nvim/lua".source = ./nvim/lua;
    # Read-only seed; Lazy writes its working lockfile under stdpath("data").
    "nvim/lazy-lock.seed.json".source = ./nvim/lazy-lock.json;
  };

  programs.vim = {
    enable = true;
    plugins = vimPlugins;
  };
}
