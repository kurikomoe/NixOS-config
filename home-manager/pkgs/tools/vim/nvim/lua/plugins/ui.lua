-- lua/plugins/ui.lua
-- 状态栏、图标、缩进线、色彩主题
-- 状态栏：lualine（替代 airline）

return {
  ------------------------------------------------------------
  -- Lualine 状态栏
  ------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        icons_enabled = true,
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "neo-tree", "TelescopePrompt" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "neo-tree", "lazy", "mason", "quickfix" },
    },
  },

  ------------------------------------------------------------
  -- 顶部 tab / buffer 栏
  ------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "tabs",
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  ------------------------------------------------------------
  -- 图标
  ------------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", lazy = true },

  ------------------------------------------------------------
  -- 缩进线
  ------------------------------------------------------------
  {
    "Yggdroot/indentLine",
    event = "BufReadPost",
    init = function()
      vim.g.indentLine_setConceal = 0
      vim.g.indentLine_char = "|"
      vim.g.indentLine_color_term = 239
      vim.g.vim_markdown_conceal = 0
    end,
  },

  ------------------------------------------------------------
  -- 主题合集
  ------------------------------------------------------------
  {
    "flazz/vim-colorschemes",
    lazy = false,
    priority = 1000,
  },
  {
    "rafi/awesome-vim-colorschemes",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("PaperColor")
    end,
  },
  {
    "altercation/vim-colors-solarized",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.solarized_termcolors = 256
    end,
  },
}
