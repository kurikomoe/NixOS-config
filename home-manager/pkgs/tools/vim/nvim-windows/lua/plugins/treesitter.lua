local function can_install()
  local missing = {}
  for _, command in ipairs({ "tree-sitter", "curl", "tar" }) do
    if vim.fn.executable(command) == 0 then
      table.insert(missing, command)
    end
  end
  local compiler = false
  for _, command in ipairs({ vim.env.CC or "cc", "gcc", "clang", "cl" }) do
    compiler = compiler or vim.fn.executable(command) == 1
  end
  if not compiler then
    table.insert(missing, "C 编译器（例如 MinGW gcc）")
  end
  if #missing > 0 then
    vim.notify(
      "跳过 Treesitter parser 安装，缺少：" .. table.concat(missing, ", ")
        .. "。安装后重启 Neovim；已有 parser 仍可使用。",
      vim.log.levels.WARN
    )
    return false
  end
  return true
end

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
    build = function()
      if can_install() then
        require("nvim-treesitter").update():wait(300000)
      end
    end,
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
      if #missing > 0 and can_install() then
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
