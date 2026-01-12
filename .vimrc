set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd
" Display line numbers
set number
" Highlight the current row
set cursorline
set virtualedit=onemore
set smartindent
set showmatch
set laststatus=2
set wildmode=list:longest
nnoremap j gj
nnoremap k gk
syntax enable
set list
set listchars+=eol:$
set expandtab
set tabstop=2
set shiftwidth=2
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
colorscheme iceberg

" Remove trailing spaces before save.
autocmd BufWritePre * :%s/\s\+$//ge
