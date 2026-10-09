-- 配置可直接复制到 Windows 配置目录；插件和运行锁文件保存在数据目录。
local data = vim.fn.stdpath("data")
local lazypath = data .. "/lazy/lazy.nvim"
local lockfile = data .. "/lazy-lock.json"
local seed = vim.fn.stdpath("config") .. "/lazy-lock.json"
vim.fn.mkdir(data, "p")
if vim.fn.filereadable(lockfile) == 0 and vim.fn.filereadable(seed) == 1 then
  vim.fn.writefile(vim.fn.readfile(seed), lockfile)
end

if not vim.uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
  if vim.fn.executable("git") == 0 then
    vim.notify("找不到 git.exe。请安装 Git 并重新打开终端；基本编辑仍可使用。", vim.log.levels.ERROR)
    return
  end
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "Lazy 安装失败，基本编辑仍可使用。恢复网络后重新启动。\n" .. result,
      vim.log.levels.ERROR
    )
    return
  end
  -- 首次 bootstrap 也使用版本基线中的 Lazy 自身版本。
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  end)
  if ok and lock["lazy.nvim"] then
    local output = vim.fn.system({ "git", "-C", lazypath, "checkout", lock["lazy.nvim"].commit })
    if vim.v.shell_error ~= 0 then
      vim.notify("Lazy 版本基线 checkout 失败：\n" .. output, vim.log.levels.WARN)
    end
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = { { import = "plugins" } },
  lockfile = lockfile,
  checker = { enabled = false },
  rocks = { enabled = false },
  install = { colorscheme = { "habamax" } },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
