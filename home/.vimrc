syntax on
set number
set mouse=a
:filetype plugin on
let $PYTHONPATH="/usr/lib/python3.3/site-packages"
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
set laststatus=2
set nocompatible
"let g:Powerline_symbols = 'unicode'
let g:Powerline_symbols = 'fancy'
let NERDTreeShowBookmarks=1
let NERDTreeMinimalUI=1
let NERDTreeMouseMode=2
let NERDTreeChDirMode=2
let NERDTreeKeepTreeInNewTab=1
nmap <silent> <F3> :NERDTreeToggle<CR>
autocmd VimEnter * NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
