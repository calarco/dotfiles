set nocompatible
set t_Co=256
set enc=utf-8
set background=dark
let g:hybrid_custom_term_colors = 1
let g:hybrid_reduced_contrast = 1
let g:enable_bold_font = 1
syntax on

set list
set listchars=tab:\|\ ,trail:·,extends:►,precedes:◄ ",eol:◊
set matchpairs+=<:>
hi SpecialKey ctermfg=0
hi Pmenu ctermbg=7 ctermfg=0 gui=bold

set mouse=a
:filetype plugin on
:au FocusLost * silent! wa
set autowrite
set cursorline
hi CursorLine cterm=NONE ctermbg=0
set relativenumber number
set scrolloff=10
hi LineNr ctermfg=243 ctermbg=0
set fillchars+=vert:\ 
hi VertSplit ctermfg=8 ctermbg=0

set wildmenu			" enhanced tab-completion shows all matching cmds in a popup menu
"set nobackup			 " disable backup files (filename~)
"set noswapfile			 " do not write annoying intermediate swap files

set tabstop=4			" tabs appear as n number of columns
set softtabstop=4		" number of spaces in tab when editing
set shiftwidth=4		" n cols for auto-indenting
autocmd! bufreadpost * set noexpandtab | retab! 4
"set expandtab			 " insert spaces instead of tabs
set autoindent			" auto indents next new line
set backspace=2			" full backspacing capabilities (indent,eol,start)
set ruler				" show line and column number
set linebreak			" attempt to wrap lines cleanly
"set cpoptions=ces$		 " `cw` put dollar sign at the end

set hlsearch			" highlight all search results
set incsearch			" show match for partly typed search command
set ignorecase			" case-insensitive search
set smartcase			" override 'ignorecase' when pattern has upper case characters

"let g:Powerline_symbols = 'unicode'
"let g:Powerline_symbols = 'fancy'
"let NERDTreeShowBookmarks = 1
"let NERDTreeMinimalUI = 1
"let NERDTreeMouseMode = 2
"let NERDTreeChDirMode = 2
"let NERDTreeKeepTreeInNewTab = 1
"nmap <silent> <F3> :NERDTreeToggle<CR>
"autocmd VimEnter * NERDTree
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

"Airline Settings:
set laststatus=2
let g:airline_theme = 'solarized'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 1

set ssop-=options
set ssop-=folds
let g:session_autoload = 'yes'
let g:session_default_to_last = 1
let g:session_autosave = 'yes'

let g:user_emmet_expandabbr_key = '<c-e>'
let g:use_emmet_complete_tag = 1
