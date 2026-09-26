-- lua/plugins/explorer.lua
-- 文件树：neo-tree.nvim（纯 Lua，替代 NERDTree）
-- CtrlP 已被 telescope 取代，不再声明

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>T", "<cmd>Neotree toggle<CR>", desc = "Neo-tree: toggle" },
      { "<leader>t", "<cmd>Neotree reveal<CR>", desc = "Neo-tree: reveal current file" },
      { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Neo-tree: focus" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          with_markers = true,
          with_expanders = true,
        },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            "__pycache__",
            "node_modules",
            ".DS_Store",
            "target",
            "build",
          },
          never_show = {
            ".git",
          },
        },
      },
    },
  },
}
