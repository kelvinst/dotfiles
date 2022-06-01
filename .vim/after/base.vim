let mapleader = ","
set clipboard=unnamed
set cmdheight=2
set colorcolumn=81,99
set cursorline
set encoding=utf-8
set hidden
set ignorecase
set laststatus=2
set nobackup
set nowritebackup
set noswapfile
set shortmess+=c
set showtabline=2
set signcolumn=number
set splitright
set splitbelow
set termguicolors
set updatetime=300
set hlsearch

nmap gb gT

nnoremap <leader>cff :let @*=expand("%")<cr>
nnoremap <leader>cfl :let @*=expand("%").":".line(".")<cr>
