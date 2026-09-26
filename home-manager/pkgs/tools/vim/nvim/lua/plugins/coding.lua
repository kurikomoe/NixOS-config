-- lua/plugins/coding.lua
-- 语言特化 & 语言相关小工具
--
-- 说明：前端代码格式化已交给 conform.nvim + prettier，
-- 原来的 vim-jsbeautify 不再需要，若确实想保留可自行加回。

return {
  ------------------------------------------------------------
  -- Zig
  ------------------------------------------------------------
  {
    "ziglang/zig.vim",
    ft = "zig",
    init = function()
      -- 交由 conform 处理保存时格式化
      vim.g.zig_fmt_autosave = 0
    end,
  },
}
