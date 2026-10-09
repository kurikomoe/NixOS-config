-- lua/plugins/motion.lua
-- 光标移动 / 跳转 / 注释 / 窗口交换

return {
  ------------------------------------------------------------
  -- Sneak
  ------------------------------------------------------------
  {
    "justinmk/vim-sneak",
    keys = {
      { "f", "<Plug>Sneak_s", mode = { "n", "v", "o" }, desc = "Sneak forward" },
      { "F", "<Plug>Sneak_S", mode = { "n", "v", "o" }, desc = "Sneak backward" },
    },
  },

  ------------------------------------------------------------
  -- EasyMotion
  ------------------------------------------------------------
  {
    "easymotion/vim-easymotion",
    keys = {
      {
        "<Leader>f",
        "<Plug>(easymotion-bd-f)",
        mode = { "n", "v", "o" },
        desc = "EasyMotion char",
      },
      { "<Leader>wf", "<Plug>(easymotion-overwin-f)", mode = "n", desc = "EasyMotion overwin f" },
      { "s", "<Plug>(easymotion-overwin-f2)", mode = "n", desc = "EasyMotion overwin f2" },
      {
        "<Leader>wl",
        "<Plug>(easymotion-bd-jk)",
        mode = { "n", "v", "o" },
        desc = "EasyMotion line",
      },
      {
        "<Leader>L",
        "<Plug>(easymotion-overwin-line)",
        mode = "n",
        desc = "EasyMotion overwin line",
      },
      {
        "<Leader>ww",
        "<Plug>(easymotion-bd-w)",
        mode = { "n", "v", "o" },
        desc = "EasyMotion word",
      },
      { "<Leader>W", "<Plug>(easymotion-overwin-w)", mode = "n", desc = "EasyMotion overwin word" },
    },
  },

  ------------------------------------------------------------
  -- NERDCommenter
  ------------------------------------------------------------
  {
    "preservim/nerdcommenter",
    keys = {
      { "<C-c>", "<Plug>NERDCommenterToggle", mode = { "n", "v" }, desc = "Toggle Comment" },
      {
        "<C-_>",
        "<leader>c<space>",
        mode = { "n", "v" },
        remap = true,
        desc = "Toggle Comment (Ctrl+/)",
      },
      {
        "<C-/>",
        "<leader>c<space>",
        mode = { "n", "v" },
        remap = true,
        desc = "Toggle Comment (Ctrl+/ alt)",
      },
    },
    init = function()
      vim.g.NERDSpaceDelims = 1
      vim.g.NERDCompactSexyComs = 1
      vim.g.NERDDefaultAlign = "left"
      vim.g.NERDAltDelims_java = 1
      vim.g.NERDCustomDelimiters = { c = { left = "/**", right = "*/" } }
      vim.g.NERDCommentEmptyLines = 1
      vim.g.NERDTrimTrailingWhitespace = 1
    end,
  },

  ------------------------------------------------------------
  -- Undotree
  ------------------------------------------------------------
  {
    "mbbill/undotree",
    cond = function()
      return vim.fn.executable("diff.exe") == 1
    end,
    cmd = { "UndotreeToggle", "UndotreeFocus" },
    keys = {
      { "<leader>U", ":UndotreeToggle<CR>", desc = "Undotree Toggle", silent = true },
      { "<leader>u", ":UndotreeFocus<CR>", desc = "Undotree Focus", silent = true },
    },
    init = function()
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_SetFocusWhenToggle = 1
      -- 使用可执行文件名，避免 PowerShell 的 diff（Compare-Object 别名）。
      vim.g.undotree_DiffCommand = "diff.exe"
    end,
  },

  ------------------------------------------------------------
  -- Windowswap
  ------------------------------------------------------------
  {
    "wesQ3/vim-windowswap",
    keys = {
      { "<C-m>", ":call WindowSwap#EasyWindowSwap()<CR>", desc = "Window Swap", silent = true },
    },
    init = function()
      vim.g.windowswap_map_keys = 0
    end,
  },

  ------------------------------------------------------------
  -- 空白清理
  ------------------------------------------------------------
  {
    "ntpeters/vim-better-whitespace",
    event = "BufReadPre",
    init = function()
      vim.g.strip_whitelines_at_eof = 0
      vim.g.strip_whitespace_on_save = 0
      vim.g.strip_max_file_size = 100000
      vim.g.strip_whitespace_confirm = 0
    end,
  },
}
