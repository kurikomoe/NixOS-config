" 基础设置
syntax on
filetype indent on
set nu
" set relativenumber
set nocursorline
noremap n nzz
set nowrap
set ignorecase
set smartcase
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
set encoding=utf8
" au VimEnter * set synmaxcol=160
set ttyfast
set lazyredraw
set mouse=a
set autoread
set t_co=256
set cc=80
set backspace=indent,eol,start

set exrc
set secure
"
" set cursorline
" set cursorcolumn

autocmd FileType make set noexpandtab

" Disable EX mode
map Q <Nop>

"Ctrl-c to copy in + buffer from visual mode
vmap <C-c> "+y

if has('gui_running')
  " set guifont=*

  " 设置tab仅显示文件名
  set guitablabel=%t

  " set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
end


" nvim 设置
if has('nvim')
  nmap <F5> :terminal <cr>
  tnoremap <Esc> <C-\><C-n>
end

" 检查 Cursor 下面的高亮
map <leader>h :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" 颜色主题设定区
if has("gui_running")
  colorscheme nord
  " colorscheme PaperColor
  set guifont=MesloLGLDZNerdFontCompleteM-Regular:h12

  nmap <D-/>   <plug>NERDCommenterInvert
  vmap <D-/>   <Plug>NERDCommenterInvert<CR>
else
  silent! colorscheme nord
end

hi IncSearch ctermfg=0 ctermbg=229 guifg=#000000 guibg=#ffffaf
hi Statement ctermfg=183
hi WarningMsg ctermbg=none
" 选中行高亮设置
hi CursorLine cterm=None ctermbg=darkred ctermfg=lightred
hi Todo cterm=bold,reverse ctermfg=3 gui=bold,reverse guifg=#6272a4
" 设置折叠高亮
hi Conceal ctermfg=7

" pmenu 的颜色调教
hi Pmenu ctermfg=255 ctermbg=239
hi PmenuSel ctermbg=darkred ctermfg=lightred
hi Function ctermfg=194
hi Folded ctermbg=None ctermfg=2
hi Keyword ctermfg=159
hi Directory ctermfg=159

" mark 颜色设定
hi SignatureMarkText ctermfg=3
hi SignatureMarkerText ctermfg=10 ctermbg=242
hi Comment ctermfg=2

hi TabLine ctermfg=black ctermbg=255

hi TagbarHighlight  ctermfg=red cterm=None ctermbg=None

hi Type ctermfg=2

" hi SpellCap term=Reverse ctermbg=15
hi SpellCap ctermbg=none ctermfg=red
hi SpellBad cterm=underline,bold ctermfg=none ctermbg=none

" you can add these colors to your .vimrc to help customizing
let s:brown = "905532"
let s:aqua =  "3AFFDB"
let s:blue = "689FB6"
let s:darkBlue = "44788E"
let s:purple = "834F79"
let s:lightPurple = "834F79"
let s:red = "AE403F"
let s:beige = "F5C06F"
let s:yellow = "F09F17"
let s:orange = "D4843E"
let s:darkOrange = "F16529"
let s:pink = "CB6F6F"
let s:salmon = "EE6E73"
let s:green = "8FAA54"
let s:lightGreen = "31B53E"
let s:white = "FFFFFF"
let s:rspec_red = 'FE405F'
let s:git_orange = 'F54D27'

hi Visual ctermfg=White ctermbg=0


let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_extensions = ['branch']
let g:airline#extensions#tabline#show_buffers = 0
let airline#extensions#tabline#ignore_bufadd_pat ='\c\vgundo|undotree|vimfiler|tagbar|nerd_tree'
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#enabled = 1

let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#close_symbol = 'X'
let g:airline#extensions#tabline#show_close_button = 1


" markdown conceal level
" set conceallevel=0
" autocmd BufEnter * set conceallevel=0
" autocmd FileType nerdtree setlocal conceallevel=3
let g:nerdtree_sync_cursorline = 1
let g:vim_markdown_conceal = 0

" 禁止indentline覆盖conceallevel设定
let g:indentLine_setConceal=0
"
" Indent Line
let g:indentLine_char = '|'
" Vim
let g:indentLine_color_term = 239

" 撤销
imap <C-z> <ESC>ui

" Plugin配置位置

let g:airline_theme='papercolor'

" 开启TagBar"
nmap <F8> :TagbarToggle<CR>

nmap <F4> :Ack!<space>

" Tagbar 自动聚焦
let g:tagbar_autofocus = 1
" let g:tagbar_autoclose = 1
" let g:tagbar_autoshowtag = 1
" let g:tagbar_autopreview = 1

" 代替f F,两字符查找
map f <Plug>Sneak_s
map F <Plug>Sneak_S

" Nerdcommentary 设置
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

let g:nerdtree_tabs_smart_startup_focus = 2
let g:nerdtree_tabs_meaningful_tab_names = 1
let g:nerdtree_tabs_synchronize_view = 1
let g:nerdtree_tabs_autofind = 0

nmap <C-_> <leader>c<space>
vmap <C-_> <leader>c<space>

nmap <C-/> <leader>c<space>
vmap <C-/> <leader>c<space>

" nmap <C-m> <leader>c<space>
" vmap <C-m> <leader>c<space>

nmap <C-c>   <Plug>NERDCommenterToggle
vmap <C-c>   <Plug>NERDCommenterToggle

" NerdTree
map <leader><S-t> :NERDTreeToggle<CR>

let NERDTreeIgnore=['__pycache__$[[dir]]', 'node_modules$[[dir]]', '*\.pyc$', '\.vim$', 'build', 'target']

" 自动关闭NerdTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" 自动清除空格
let g:strip_whitelines_at_eof=0
let g:strip_whitespace_on_save = 1
let g:strip_max_file_size = 1000
let g:strip_whitespace_confirm=0


" EasyMotion 跨窗口跳转
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>wf <Plug>(easymotion-overwin-f)

nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>wl <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>ww <Plug>(easymotion-bd-w)
nmap <Leader>W <Plug>(easymotion-overwin-w)

let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1


let g:NERDTreeExtensionHighlightColor = {} " this line is needed to avoid error
let g:NERDTreeExtensionHighlightColor['css'] = s:blue " sets the color of css files to blue

let g:NERDTreeExactMatchHighlightColor = {} " this line is needed to avoid error
let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange " sets the color for .gitignore files

let g:NERDTreePatternMatchHighlightColor = {} " this line is needed to avoid error
let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red " sets the color for files ending with _spec.rb

" 自动关闭NerdTree 为了和DWM兼容
" let g:NERDTreeQuitOnOpen = 1

let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableNERDTreeRedraw = 1


" NERDTree 聚焦
map <leader>t :NERDTreeTabsFind<CR>

" set autochdir
let g:auto_ctags_directory_list = ['.git', '.svn'] " 优先在这些目录存放ctags
let g:auto_ctags = 1

let g:easytags_async = 1

" Updatetags
" map <leader>r :UpdateTags<CR>

" 行内跳转
noremap j gj
noremap k gk

" UndoTree Settings
if has("persistent_undo")
  set undodir=~/.undodir/
  set undofile
endif
let g:undotree_WindowLayout = 3
function! ClearUndo()
  let choice = 1
  if choice == 1
    let old_undolevels = &undolevels
    set undolevels=-1
    exe "normal a \<Bs>\<Esc>"
    let &undolevels = old_undolevels
  endif
endfunction
map <leader>du :call ClearUndo()<CR>

" 开启UndoTree
nnoremap <leader>U :UndotreeToggle<cr>
nnoremap <leader>u :UndotreeFocus<cr>
let g:undotree_SetFocusWhenToggle=1

let delimitMate_expand_cr = 2

" 解决NerdTree中只有半个图标的问题
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '

let s:myFileName = expand("%:p")

function! MySaveSession()
  execute ":UndotreeHide"
  " execute ":NERDTreeFocus"
  execute ":silent SaveSession! ".s:myFileName
  execute ":redraw!"
endf
function! MyOpenSession()
  execute ":silent OpenSession! ".s:myFileName
  execute ":redraw!"
endf


let g:session_autoload = 'no'
let g:session_autosave = 'no'


set grepprg=grep\ -nH\ $*
let g:tex_flavor='xelatex'
let g:tex_conceal = ""


silent! imap <C-k> <Plug>delimitMateS-Tab
" 跳出括号快捷键
" silent! imap <C-o> <Plug>delimitMateS-Tab

" 启用彩虹括号
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle"

" 自动改变光标
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" 更好的resize设置
let g:winresizer_vert_resize = 1
let g:winresizer_horiz_resize = 1


" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-f>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" CTRLP
let g:ctrlp_map = '<c-p>'
nnoremap <c-f> :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <c-h> :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
let g:ctrlp_working_path_mode = 'w'

" Ctrlp 忽略文件列表
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)|node_modules$|target|build',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }


" 快速切换tabs
noremap <silent><tab>1 :tabn 1<cr>
noremap <silent><tab>2 :tabn 2<cr>
noremap <silent><tab>3 :tabn 3<cr>
noremap <silent><tab>4 :tabn 4<cr>
noremap <silent><tab>5 :tabn 5<cr>
noremap <silent><tab>6 :tabn 6<cr>
noremap <silent><tab>7 :tabn 7<cr>
noremap <silent><tab>8 :tabn 8<cr>
noremap <silent><tab>9 :tabn 9<cr>
noremap <silent><tab>0 :tabn 10<cr>
noremap <silent><tab>p :tabp<cr>
noremap <silent><tab>n :tabn<cr>
noremap <silent><tab>j :tabp<cr>
noremap <silent><tab>k :tabn<cr>
noremap <silent><tab>h :tabmove -1<cr>
noremap <silent><tab>l :tabmove +1<cr>

" Alt 映射
noremap <silent><M-1> :tabn 1<cr>
noremap <silent><M-2> :tabn 2<cr>
noremap <silent><M-3> :tabn 3<cr>
noremap <silent><M-4> :tabn 4<cr>
noremap <silent><M-5> :tabn 5<cr>
noremap <silent><M-6> :tabn 6<cr>
noremap <silent><M-7> :tabn 7<cr>
noremap <silent><M-8> :tabn 8<cr>
noremap <silent><M-9> :tabn 9<cr>
noremap <silent><M-0> :tabn 10<cr>
" 删除所有的未显示buffers，希望能提高一些性能
nmap <Tab><BS> :DeleteHiddenBuffers<CR>
nmap <Tab><Del> :tabclose<CR>


" 搜索高亮
vnoremap // y/<C-R>"<CR>

" 各种css html js json代码美化
autocmd FileType javascript noremap <buffer>  <leader>b :call JsBeautify()<cr>
" for json
autocmd FileType json noremap <buffer> <leader>b :call JsonBeautify()<cr>
" for jsx
autocmd FileType jsx noremap <buffer> <leader>b :call JsxBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <leader>b :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <leader>b :call CSSBeautify()<cr>

" Hex Mode
let g:hexmode_autodetect = 1

" Winresizer
let g:winresizer_start_key="<leader>e"

" 方便的panel交换
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <C-m> :call WindowSwap#EasyWindowSwap()<CR>

" 使用Tab进行补全
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

let g:solarized_termcolors = 256

augroup remember_folds
  autocmd!
  autocmd BufWinLeave silent! mkview
  autocmd BufWinEnter silent! loadview
augroup END

let g:asyncomplete_auto_popup = 1
imap <c-d> <Plug>(asyncomplete_force_refresh)

let g:strip_max_file_size = 100000

let g:OmniSharp_log_dir = "$HOME/.cache/omnisharp-vim"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

set clipboard+=unnamedplus


" 应该放在最最最后的代码
if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif
