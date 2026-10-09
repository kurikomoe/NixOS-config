-- lua/config/highlights.lua
-- 保留原 vimrc 的自定义高亮；放在插件加载之后，避免被 colorscheme 覆盖

local function hi(cmd)
  pcall(vim.cmd, cmd)
end

-- 让 colorscheme 生效以后再叠加自定义高亮
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserHighlights", { clear = true }),
  pattern = "*",
  callback = function()
    -- PaperColor 使用自身完整配色，避免旧高亮覆盖主题。
    if vim.g.colors_name == "PaperColor" then
      return
    end
    hi("hi IncSearch ctermfg=0 ctermbg=229 guifg=#000000 guibg=#ffffaf")
    hi("hi Statement ctermfg=183")
    hi("hi WarningMsg ctermbg=none")
    hi("hi CursorLine cterm=None ctermbg=darkred ctermfg=lightred")
    hi("hi Todo cterm=bold,reverse ctermfg=3 gui=bold,reverse guifg=#6272a4")
    hi("hi Conceal ctermfg=7")
    hi("hi Pmenu ctermfg=255 ctermbg=239")
    hi("hi PmenuSel ctermbg=darkred ctermfg=lightred")
    hi("hi Function ctermfg=194")
    hi("hi Folded ctermbg=None ctermfg=2")
    hi("hi Keyword ctermfg=159")
    hi("hi Directory ctermfg=159")
    hi("hi SignatureMarkText ctermfg=3")
    hi("hi SignatureMarkerText ctermfg=10 ctermbg=242")
    hi("hi Comment ctermfg=2")
    hi("hi TabLineSel ctermfg=black ctermbg=white")
    hi("hi TagbarHighlight ctermfg=red cterm=None ctermbg=None")
    hi("hi Type ctermfg=2")
    hi("hi SpellCap ctermbg=none ctermfg=red")
    hi("hi SpellBad cterm=underline,bold ctermfg=none ctermbg=none")
    hi("hi Visual ctermfg=White ctermbg=0")
  end,
})

-- 初次也触发一次，避免第一次启动时颜色没上
pcall(vim.cmd, "doautocmd ColorScheme")
