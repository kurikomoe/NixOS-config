-- lua/plugins/telescope.lua
-- 现代 fuzzy finder：文件 / grep / buffer / LSP 结果 等
-- 替代 CtrlP / coc-fzf；Leader+p 避免与 EasyMotion 的 Leader+f 冲突。

local function symbols()
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/documentSymbol" }) == 0 then
    vim.notify("当前 buffer 没有提供文档符号的 LSP。", vim.log.levels.INFO)
    return
  end
  require("telescope.builtin").lsp_document_symbols()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- 使用内置 Lua sorter，Windows 首次启动不需要编译 fzf-native。
      -- 文件类型图标
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<F4>", "<cmd>Telescope live_grep<CR>", desc = "Search project" },
      { "<F8>", symbols, desc = "Document symbols" },
      { "<C-f>", symbols, desc = "Document symbols" },
      { "<C-h>", "<cmd>Telescope grep_string<CR>", desc = "Search word" },
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Telescope: find files (Ctrl+P)" },
      { "<leader>pf", "<cmd>Telescope find_files<CR>", desc = "Telescope: find files" },
      { "<leader>pg", "<cmd>Telescope live_grep<CR>", desc = "Telescope: live grep" },
      { "<leader>pb", "<cmd>Telescope buffers<CR>", desc = "Telescope: buffers" },
      { "<leader>ph", "<cmd>Telescope help_tags<CR>", desc = "Telescope: help tags" },
      { "<leader>pr", "<cmd>Telescope oldfiles<CR>", desc = "Telescope: recent files" },
      { "<leader>pw", "<cmd>Telescope grep_string<CR>", desc = "Telescope: grep current word" },
      { "<leader>pd", "<cmd>Telescope diagnostics<CR>", desc = "Telescope: diagnostics" },
      { "<leader>ps", symbols, desc = "Telescope: document symbols" },
      {
        "<leader>pS",
        "<cmd>Telescope lsp_workspace_symbols<CR>",
        desc = "Telescope: workspace symbols",
      },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Telescope: git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Telescope: git status" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "▶ ",
          path_display = { "smart" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.9,
            height = 0.85,
          },
          file_ignore_patterns = {
            "%.git[/\\]",
            "node_modules[/\\]",
            "target[/\\]",
            "build[/\\]",
            "__pycache__[/\\]",
            "%.pyc",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
    end,
  },
}
