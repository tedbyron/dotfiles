set nocompatible

" colorscheme
set t_Co=256
colorscheme dracula
let g:lightline={'colorscheme': 'dracula'}

" syntax highlighting
if has('syntax')
  syntax on
endif

" enable mouse in all modes
if has('mouse')
  set mouse=a
endif

" cmdline-history
set history=500

" read file if changed externally
set autoread

" layout
set number
set ruler
set cursorline
set autoindent
set smartindent
set wrap
set linebreak
set nolist
set textwidth=0
set wrapmargin=0
set expandtab
set shiftwidth=2
set softtabstop=2
set laststatus=2
set scrolloff=5

" commands
set wildmenu
set wildmode=list:longest,full
set showcmd
" set cmdheight=2
set visualbell
set t_vb=

" search
set ignorecase
set smartcase
set hlsearch
set incsearch
set magic
set noshowmode

" use system clipboard
set clipboard^=unnamed,unnamedplus

" show matching {bracket,brace,paren} when inserted
set showmatch

" backspace over autoindent, line breaks, and start of insert action
set backspace=indent,eol,start

" timeout on keycodes but not mappings
set notimeout ttimeout ttimeoutlen=200

" don't write backup/swap files
set nobackup
set nowritebackup
set noswapfile

" don't use background color
hi Normal ctermbg=NONE
hi LineNr ctermbg=NONE

let mapleader=' '
inoremap <S-Tab> <C-d>
