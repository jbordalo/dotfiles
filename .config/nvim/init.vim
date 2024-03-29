set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set nowrap
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set smartindent
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.
set undodir=~/.vimid
set undofile
" Move lines with Alt Arrow
nnoremap <A-Up> :m .-2<CR>==
nnoremap <A-Down> :m .+1<CR>==
inoremap <A-Up> <Esc> :m .-2<CR>==gi
inoremap <A-Down> <Esc> :m .+1<CR>==gi
" shift-tab
" for command mode
nnoremap <S-Tab> <<
" for insert mode
inoremap <S-Tab> <C-d>

nnoremap <C-W> db
nnoremap <C-U> d0

" saving
nnoremap <C-S> :w <CR>==
inoremap <C-S> <Esc>:w <CR>==gi

call plug#begin()

Plug 'rstacruz/vim-closer'

call plug#end()
