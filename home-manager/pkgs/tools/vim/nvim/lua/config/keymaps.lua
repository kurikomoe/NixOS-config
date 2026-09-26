-- lua/config/keymaps.lua
-- 与插件无关的通用按键映射；插件相关映射放在各自的 plugin spec 里

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- 禁用 Ex 模式
map({ "n", "v" }, "Q", "<Nop>", opts)

-- n 保持居中
map("n", "n", "nzz", opts)

-- 视觉行移动
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- Ctrl+C 的注释映射统一放在 plugins/motion.lua。

-- 终端：Esc 退出
map("t", "<Esc>", [[<C-\><C-n>]], opts)
map("n", "<F5>", ":terminal<CR>", opts)

-- 快速搜索选中内容
map("v", "//", [[y/<C-R>"<CR>]], opts)

-- Tab 快速切换（保持原 vimrc 习惯）
for i = 1, 9 do
  map("n", "<Tab>" .. i, ":tabn " .. i .. "<CR>", opts)
  map("n", "<M-" .. i .. ">", ":tabn " .. i .. "<CR>", opts)
end
map("n", "<Tab>0", ":tabn 10<CR>", opts)
map("n", "<M-0>", ":tabn 10<CR>", opts)
map("n", "<Tab>p", ":tabp<CR>", opts)
map("n", "<Tab>n", ":tabn<CR>", opts)
map("n", "<Tab>j", ":tabp<CR>", opts)
map("n", "<Tab>k", ":tabn<CR>", opts)
map("n", "<Tab>h", ":tabmove -1<CR>", opts)
map("n", "<Tab>l", ":tabmove +1<CR>", opts)
map("n", "<Tab><Del>", ":tabclose<CR>", opts)

-- 补全弹窗的 <Tab>/<S-Tab>/<CR> 交给 nvim-cmp 处理（见 lua/plugins/cmp.lua）

map("i", "<C-z>", "<Esc>ui", opts)
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, opts)
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<leader>q", vim.diagnostic.setloclist, opts)
-- 不占用 Git hunk 操作的 Leader+h 前缀。
map("n", "<leader>H", "<cmd>Inspect<CR>", { desc = "Inspect highlight", silent = true })

vim.api.nvim_create_user_command("FormatToggle", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify(
    "当前 buffer 保存时格式化：" .. (vim.b.disable_autoformat and "关闭" or "开启")
  )
end, { desc = "Toggle format on save for this buffer" })

vim.api.nvim_create_user_command("DeleteHiddenBuffers", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and not vim.bo[buf].modified
      and #vim.fn.win_findbuf(buf) == 0
    then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end, { desc = "Delete unmodified hidden file buffers" })
map("n", "<Tab><BS>", "<cmd>DeleteHiddenBuffers<CR>", opts)

vim.api.nvim_create_user_command("ClearUndo", function()
  if not vim.bo.modifiable or vim.bo.readonly then
    return
  end
  local view, modified, levels = vim.fn.winsaveview(), vim.bo.modified, vim.bo.undolevels
  vim.bo.undolevels = -1
  -- 执行一次内容不变的修改以清空撤销历史，不污染寄存器。
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line .. " ")
  vim.api.nvim_set_current_line(line)
  vim.bo.undolevels = levels
  vim.bo.modified = modified
  vim.fn.winrestview(view)
end, { desc = "Clear undo history of the current buffer" })
map("n", "<leader>du", "<cmd>ClearUndo<CR>", opts)
