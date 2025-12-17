{
  inputs,
  config,
  root,
  pkgs,
  lib,
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
    vim-polyglot

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

    coc-tabnine
    coc-cmake
    coc-git

    coc-go
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

    csharp-ls

    # vim alternative?
    helix
  ];

  # for omnisharp-vim to find the executable
  home.sessionPath = [
    "$HOME/.cache/omnisharp-vim/omnisharp-roslyn"
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraConfig =
      (builtins.readFile ./nvim/init.vim)
      + ''        ;
              " set log dir to avoid write into /nix
              " let g:OmniSharp_log_dir = "$HOME/.cache/omnisharp-vim"
              " let g:OmniSharp_server_use_mono = 1

              " Make <CR> to accept selected completion item or notify coc.nvim to format
              " <C-g>u breaks current undo, please make your own choice
              inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      '';
    extraLuaConfig = ''
      vim.lsp.config["csharp_ls"] = {
        root_marker = { "*.sln", "*.csproj", },
        handlers = {
          ["textDocument/definition"] = require('csharpls_extended').handler,
          ["textDocument/typeDefinition"] = require('csharpls_extended').handler,
        },
        cmd = { "csharp-ls" },
      }
      vim.lsp.enable("csharp_ls")
      require("csharpls_extended").buf_read_cmd_bind()
    '';
    plugins = vimPlugins;
    coc = {
      enable = true;
      settings = lib.importJSON ./nvim/coc-settings.json;
    };
  };

  programs.vim = {
    enable = true;
    plugins = vimPlugins;
  };
}
