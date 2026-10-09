local group = vim.api.nvim_create_augroup("UserEditing", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "make",
  callback = function(args)
    vim.bo[args.buf].expandtab = false
  end,
})

-- 仅保存真实文件的视图，避免文件树、终端及临时窗口产生 view 文件。
local function is_file(buf)
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = group,
  callback = function(args)
    if is_file(args.buf) then
      vim.cmd("silent! mkview")
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(args)
    if is_file(args.buf) then
      vim.cmd("silent! loadview")
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = "*.*.age",
  callback = function(args)
    local ext = vim.fn.fnamemodify(args.file, ":r:e")
    local aliases =
      { py = "python", js = "javascript", ts = "typescript", md = "markdown", yml = "yaml" }
    vim.bo[args.buf].filetype = aliases[ext] or ext
  end,
})
