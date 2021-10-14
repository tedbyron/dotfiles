" packages: dracula, lightline, fugitive, surround, vim-gitgutter,
" nerdcommenter

colorscheme dracula
let g:lightline={'colorscheme': 'dracula'}

syntax on
set t_Co=256
set history=500
set mouse=a
set number
set ruler
set autoread
set ai
set si
set wrap
set linebreak
set nolist
set textwidth=0
set wrapmargin=0
set ignorecase
set smartcase
set hlsearch
set nohls
set incsearch
set magic
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set showmatch
set showcmd
set showmode
set wildmenu
set wildmode=list:longest,full
set scrolloff=5
set cursorline
set noshowmode
set clipboard^=unnamed,unnamedplus
set backspace=indent,eol,start

set laststatus=2
set ttimeoutlen=10

set nobackup
set nowb
set noswapfile

hi Normal ctermbg=NONE
hi LineNr ctermbg=NONE

let mapleader=' '
inoremap <S-Tab> <C-d>
