-- lua/plugins/gitsigns.lua
-- Git 状态显示 / hunk 操作，替代 coc-git

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        -- Hunk 之间跳转
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Gitsigns: next hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Gitsigns: prev hunk")

        -- Hunk 操作
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Gitsigns: stage hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Gitsigns: reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Gitsigns: stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Gitsigns: undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Gitsigns: reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Gitsigns: preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Gitsigns: blame line")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Gitsigns: toggle blame")
        map("n", "<leader>hd", gs.diffthis, "Gitsigns: diff this")
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Gitsigns: diff this ~")
        map("n", "<leader>gD", gs.preview_hunk_inline, "Gitsigns: preview deleted lines")

        -- Text object: ih 表示 in hunk
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns: select hunk")
      end,
    },
  },
}
