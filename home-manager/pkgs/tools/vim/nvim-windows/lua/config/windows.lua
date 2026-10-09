-- Windows 终端与编译环境；路径使用 stdpath/vim.fs，不依赖固定用户名或盘符。
if vim.fn.has("win32") == 0 then
  return
end

local shell = vim.fn.exepath("pwsh.exe")
local modern = shell ~= ""
if not modern then
  shell = vim.fn.exepath("powershell.exe")
end
if shell ~= "" then
  -- shell 是一个命令行选项；带空格的 Program Files 路径必须加引号。
  vim.opt.shell = '"' .. shell .. '"'
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  if modern then
    vim.opt.shellcmdflag:append("$PSStyle.OutputRendering='PlainText';")
    vim.env.__SuppressAnsiEscapeSequences = "1"
  end
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  vim.opt.shellpipe = "> %s 2>&1"
  vim.opt.shellredir = "> %s 2>&1"
  vim.opt.shelltemp = false
end

-- Scoop 的 MinGW 可直接用于 tree-sitter build；尊重用户指定的 CC。
if not vim.env.CC and vim.fn.executable("gcc") == 1 then
  vim.env.CC = "gcc"
end
