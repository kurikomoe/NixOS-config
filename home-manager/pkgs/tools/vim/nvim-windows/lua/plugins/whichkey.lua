-- lua/plugins/whichkey.lua
-- 按键提示：按下 Leader 前缀后列出后续可选项，避免只靠记忆。

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- classic 是底部整行风格，接近旧版 which-key 的观感。
      preset = "classic",
      -- 只给前缀组命名；具体键位说明来自各自映射的 desc。
      spec = {
        { "<leader>p", group = "Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks" },
        { "<leader>w", group = "EasyMotion" },
        -- nerdcommenter 的 \c* 映射在首次按 <C-c> 后才注册。
        { "<leader>c", group = "Comment" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer-local keymaps",
      },
    },
  },
}
