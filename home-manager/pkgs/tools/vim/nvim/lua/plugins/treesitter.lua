local languages = {
  "bash",
  "c",
  "cpp",
  "css",
  "html",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "nix",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "zig",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- 锁定的新版 Treesitter 不支持懒加载。
    build = ":TSUpdate",
    config = function()
      vim.treesitter.language.register("json", "jsonc")
      local treesitter = require("nvim-treesitter")
      treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
      local function highlight(buf)
        if
          vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buftype == ""
          and vim.bo[buf].filetype ~= ""
        then
          -- 缺少 parser 的文件仍可使用 Vim syntax。
          pcall(vim.treesitter.start, buf)
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
        callback = function(args)
          highlight(args.buf)
        end,
      })
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        highlight(buf)
      end
      local installed = treesitter.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, languages)
      if #missing > 0 then
        treesitter.install(missing):await(function()
          -- 首次打开的 buffer 在异步安装完成后也获得高亮。
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              highlight(buf)
            end
          end)
        end)
      end
    end,
  },
}
