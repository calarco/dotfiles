set t_Co=256
syntax on
set number
set mouse=a
:filetype plugin on
let $PYTHONPATH="/usr/lib/python3.3/site-packages"
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
set laststatus=2
set nocompatible

set wildmenu            " enhanced tab-completion shows all matching cmds in a popup menu
"set cursorline          " highlight current line
set norelativenumber    " show no relative line numbers
"set nobackup            " disable backup files (filename~)
"set noswapfile          " do not write annoying intermediate swap files
set laststatus=2        " always show the status line

set tabstop=4           " tabs appear as n number of columns
set softtabstop=4       " number of spaces in tab when editing
set shiftwidth=4        " n cols for auto-indenting
"set expandtab           " insert spaces instead of tabs
set autoindent          " auto indents next new line
set backspace=2         " full backspacing capabilities (indent,eol,start)
set ruler               " show line and column number
set linebreak           " attempt to wrap lines cleanly
"set cpoptions=ces$      " `cw` put dollar sign at the end

set hlsearch            " highlight all search results
set incsearch           " show match for partly typed search command
set ignorecase          " case-insensitive search
set smartcase           " override 'ignorecase' when pattern has upper case characters

"let g:Powerline_symbols = 'unicode'
let g:Powerline_symbols = 'fancy'
let NERDTreeShowBookmarks=1
let NERDTreeMinimalUI=1
let NERDTreeMouseMode=2
let NERDTreeChDirMode=2
let NERDTreeKeepTreeInNewTab=1
nmap <silent> <F3> :NERDTreeToggle<CR>
"autocmd VimEnter * NERDTree
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright
