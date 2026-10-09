-- lua/config/options.lua
-- 全局选项与 leader 设置

-- leader 必须在插件加载之前设置
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- 环境变量可能传入字面量 ~/ 或 ~\；Go 不会自动展开它。
-- 在 Mason 和 LSP 启动之前修正，保留项目已有的绝对路径和 GOPATH 列表。
local home = vim.fn.expand("~")
local path_separator = vim.fn.has("win32") == 1 and ";" or ":"
for _, name in ipairs({ "GOPATH", "GOMODCACHE", "GOCACHE" }) do
  local value = vim.env[name]
  if value and value ~= "" then
    local paths = name == "GOPATH" and vim.split(value, path_separator, { plain = true })
      or { value }
    for i, path in ipairs(paths) do
      if path == "~" then
        paths[i] = home
      elseif path:sub(1, 2) == "~/" or path:sub(1, 2) == "~\\" then
        paths[i] = home .. path:sub(2)
      end
    end
    vim.env[name] = table.concat(paths, path_separator)
  end
end

local opt = vim.opt

-- 显示
opt.number = true
opt.relativenumber = false
opt.cursorline = false
opt.wrap = false
opt.colorcolumn = "80"
opt.signcolumn = "yes"
opt.termguicolors = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 缩进
opt.tabstop = 2
opt.softtabstop = 0
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true

-- 编辑
opt.encoding = "utf-8"
opt.mouse = "a"
opt.autoread = true
opt.backspace = { "indent", "eol", "start" }
opt.clipboard = "unnamedplus" -- 使用 Windows 本地剪贴板，交由 Neovim 自动检测 provider。
-- 新文件默认 LF，同时识别现有 CRLF 文件并保留其换行格式。
opt.fileformats = { "unix", "dos" }

require("config.windows")

-- 性能
opt.ttyfast = true
opt.lazyredraw = false
opt.updatetime = 300
opt.timeoutlen = 500

-- 持久化 undo
if vim.fn.has("persistent_undo") == 1 then
  local undodir = vim.fn.stdpath("state") .. "/undo"
  opt.undodir = undodir
  opt.undofile = true
  if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
  end
end

-- 折叠：交给具体插件 / 语言处理，这里只给一个通用默认
opt.foldmethod = "manual"
opt.foldlevelstart = 99

-- 允许 Lua 中的 filetype plugin/indent
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
