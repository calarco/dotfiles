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
filetype plugin on
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
set breakindent
"set cpoptions=ces$		 " `cw` put dollar sign at the end

set hlsearch			" highlight all search results
set incsearch			" show match for partly typed search command
set ignorecase			" case-insensitive search
set smartcase			" override 'ignorecase' when pattern has upper case characters

set whichwrap+=<,>,h,l,[,]
nnoremap <expr> k v:count ? 'k' : 'gk'
vnoremap k gk
noremap <Up> gk
imap <Up> <C-o>gk
nnoremap <expr> j v:count ? 'j' : 'gj'
vnoremap j gj
noremap  <Down> gj
imap <Down> <C-o>gj
noremap <home> g<home>
imap <home> <C-o>g<home>
noremap <End> g<End>
imap <End> <C-o>g<End>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

set spelllang=es

autocmd BufNewFile,BufReadPost *.md set filetype=markdown

call plug#begin('~/.vim/plugged')
	Plug 'reedes/vim-colors-pencil'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'vim-pandoc/vim-pandoc'
	Plug 'vim-pandoc/vim-pandoc-syntax'
	"Plug 'reedes/vim-pencil', { 'for': 'markdown' }
	Plug 'junegunn/goyo.vim', { 'for': 'markdown' }
	"autocmd! User goyo.vim Goyo
	Plug 'junegunn/limelight.vim'
	Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
call plug#end()

let g:pencil_higher_contrast_ui = 0

set noshowmode
set laststatus=2
let g:airline_theme = 'solarized'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_min_count =2
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 1

let g:pandoc#modules#disabled = ["folding", "bibliographies", "keyboard", "toc", "executors", "hypertext"]
let g:pandoc#command#autoexec_on_writes = 1
let g:pandoc#command#autoexec_command = "Pandoc! docx --reference-docx=~/Documentos/reference.docx"
let g:pandoc#formatting#textwidth = 90

let g:goyo_width = 90
function! s:goyo_enter()
	"Pencil
	"Limelight
	set showmode
	set scrolloff=999
	if has('gui_running')
		set background=light
		set linespace=7
	endif
	let b:quitting = 0
	let b:quitting_bang = 0
	autocmd QuitPre <buffer> let b:quitting = 1
	cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
	"PencilOff
	"Limelight!
	set noshowmode
	set scrolloff=10
	if has('gui_running')
		set background=dark
		set linespace=4
	endif
	if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
		if b:quitting_bang
			qa!
		else
			qa
		endif
	endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

let g:limelight_default_coefficient = 0.3

let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1
let NERDTreeMouseMode = 2
let NERDTreeChDirMode = 2
let NERDTreeKeepTreeInNewTab = 1
nmap <silent> <F3> :NERDTreeToggle<CR>
"autocmd VimEnter * NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

set ssop-=options
set ssop-=folds
let g:session_autoload = 'yes'
let g:session_default_to_last = 1
let g:session_autosave = 'yes'

let g:user_emmet_expandabbr_key = '<c-e>'
let g:use_emmet_complete_tag = 1
