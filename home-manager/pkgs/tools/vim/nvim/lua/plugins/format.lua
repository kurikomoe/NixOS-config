return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    dependencies = { "mason-org/mason.nvim" },
    keys = {
      {
        "<leader>F",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format buffer / selection",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zig = { "zigfmt" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(buf)
        if
          vim.b[buf].disable_autoformat
          or vim.bo[buf].buftype ~= ""
          or not vim.bo[buf].modifiable
        then
          return
        end
        if vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 200 * 1024 then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}
