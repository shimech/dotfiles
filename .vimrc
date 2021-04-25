"色
set background=dark
"カラースキーム
let g:hybrid_use_iTerm_colors = 1
colorscheme hybrid

set encoding=utf-8
scriptencoding utf-8

"カーソル位置表示
set ruler
"行番号表示
set number
" ファイルを上書きする前にバックアップをとることを無効化
set nowritebackup
" ファイルを上書きする前にバックアップをとることを無効化
set nobackup

autocmd ColorScheme * highlight LineNr ctermfg=12
highlight CursorLineNr ctermbg=4 ctermfg=0
set cursorline
highlight clear CursorLine

syntax enable

set autoindent

set shiftwidth=4
set softtabstop=4
set tabstop=4

set expandtab
set smarttab

set visualbell t_vb=

set wrap

set noincsearch

set hlsearch

set ignorecase

set smartcase

set wrapscan

set gdefault

set list
set listchars=tab:>-,eol:↲,extends:»,precedes:«,nbsp:%

set wildmode=list:longest,full

set showcmd

set clipboard=unnamed,autoselect

set whichwrap=b,s,h,l,<,>,~,[,]
" 挿入モードでバックスペースで削除できるようにする
set backspace=indent,eol,start
set nrformats-=octal

set pumheight=10

set showmatch
set matchtime=1
source $VIMRUNTIME/macros/matchit.vim

set display=lastline

set hidden

"set nobackup
"set backupdir=$HOME/.vim/backup
"set noundofile
"set undodir=$HOME/.vim/backup
"set noswapfile

"カーソル移動
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <down> gj
nnoremap <up> gk
noremap <S-h> ^
noremap <S-j> }
noremap <S-k> {
noremap <S-l> $

";;でノーマルモード
inoremap ;; <esc>

"ノーマルモードのまま改行
nnoremap <CR> A<CR><ESC>
"ノーマルモードのままスペース
nnoremap <space> i<space><esc>

"rだけでリドゥ
nnoremap r <C-r>

"Yで行末までヤンク
nnoremap Y y$

"ESCキー2度押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>


"ペースト時に自動インデントで崩れるのを防ぐ
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif


filetype plugin indent on
