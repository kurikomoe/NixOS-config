-- Windows: %LOCALAPPDATA%/nvim/init.lua
-- 入口文件：只做 bootstrap + 模块加载，具体配置见 lua/config/ 和 lua/plugins/

if vim.fn.has("nvim-0.12") == 0 then
  vim.notify("此配置的插件版本要求 Neovim 0.12+，请先升级 Neovim。", vim.log.levels.ERROR)
  return
end

-- 1. 基础选项：先加载，避免有些插件在 setup 时读到默认值
require("config.options")

-- 2. 按键映射（跟插件无关的部分）
require("config.keymaps")

-- 3. 自动命令
require("config.autocmds")

-- 4. lazy.nvim 引导 + 插件加载
require("config.lazy")

-- 5. 高亮 / 主题相关（放在插件加载之后，避免被 colorscheme 覆盖）
require("config.highlights")
