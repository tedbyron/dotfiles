if empty(glob('$HOME/.vim/autoload/plug.vim'))
  silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $HOME/.vimrc
endif

call plug#begin()
Plug 'itchyny/lightline.vim'
Plug 'joshdick/onedark.vim'
call plug#end()

let g:onedark_termcolors=16
colorscheme onedark
let g:lightline={'colorscheme': 'onedark'}

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
set clipboard=unnamed

set laststatus=2
set ttimeoutlen=10

set nobackup
set nowb
set noswapfile

highlight LineNr ctermfg=darkgray
highlight CursorLine cterm=NONE ctermbg=237
highlight CursorLineNR ctermfg=gray

let mapleader=' '
