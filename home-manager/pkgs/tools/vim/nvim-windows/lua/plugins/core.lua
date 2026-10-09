-- lua/plugins/core.lua
-- 基础通用插件

return {
  { "tpope/vim-sensible", lazy = false, priority = 900 },
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-git", event = "VeryLazy" },

  -- 让光标回到上次退出位置
  { "farmergreg/vim-lastplace", event = "BufReadPre" },

  -- 表格对齐
  { "godlygeek/tabular", cmd = { "Tabularize" } },
}
