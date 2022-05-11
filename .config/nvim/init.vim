set nocompatible

call plug#begin(stdpath('data') . '/plugged')

Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sleuth'

if exists('g:vscode')
  Plug 'asvetliakov/vim-easymotion', { 'as': 'vsc-easymotion' }
else
  Plug 'preservim/nerdtree'
  Plug 'airblade/vim-gitgutter'
  Plug 'itchyny/lightline.vim'
  Plug 'folke/which-key.nvim'
  Plug 'tpope/vim-commentary'
  Plug 'easymotion/vim-easymotion'
endif

call plug#end()

if has('syntax')
  syntax on       " syntax highlighting
endif

packadd! dracula_pro
let g:dracula_colorterm = 0

set t_Co=256
colorscheme dracula_pro
let g:lightline={'colorscheme': 'dracula_pro'}

if has('mouse')
  set mouse=a     " enable mouse in all modes
endif

set history=500   " cmdline-history
set autoread      " read file if changed externally

" layout
set number relativenumber " line numbers
set ruler         " cursor line and column number
set cursorline    " highlight cursor line
set autoindent    " continue indent on newlines
set smartindent   " indent on newlines after certain chars
" set wrap          " soft wrap
set linebreak       " wrap at 'breakat' char
" set list          " show whitespace in normal mode
" set textwidth=0   " text wrap
" set wrapmargin=0  " hard wrap - only when textwidth=0
set expandtab     " tabs to spaces
set shiftwidth=4
set tabstop=4
set softtabstop=4
set laststatus=2  " always show status line
set scrolloff=3   " lines to keep above and below cursor

" commands
set wildmenu
set wildmode=list:longest,full
set showcmd
" set cmdheight=2
set visualbell
set t_vb=

" search
set path+=.;,./**
set ignorecase smartcase
set hlsearch incsearch
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

" don't use background color
hi Normal ctermbg=NONE
hi LineNr ctermbg=NONE

let mapleader=' '
inoremap <S-Tab> <C-d>

if exists('g:vscode')
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine
  nnoremap z= <Cmd>call VSCodeNotify('keyboard-quickfix.openQuickFix')<CR>
else
lua << EOF
  require("which-key").setup({}) 
EOF
endif
