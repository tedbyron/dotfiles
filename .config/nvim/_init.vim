set nocompatible

call plug#begin(stdpath('data') . '/plugged')

Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

if exists('g:vscode')
  Plug 'asvetliakov/vim-easymotion', { 'as': 'vsc-easymotion' }
else
  Plug 'airblade/vim-gitgutter'
  Plug 'dracula/vim'
  Plug 'easymotion/vim-easymotion'
  Plug 'folke/which-key.nvim'
  Plug 'itchyny/lightline.vim'
  Plug 'preservim/nerdtree'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-sleuth'
endif
call plug#end()

if has('syntax')
  syntax on       " syntax highlighting
endif

let g:dracula_colorterm = 0

set t_Co=256
colorscheme dracula
let g:lightline={'colorscheme': 'dracula'}

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
  nnoremap z- <Cmd>call VSCodeNotify('editor.action.rename')<CR>
  nnoremap <leader>hs <Cmd>call VSCodeNotify('git.stageSelectedRanges')<CR>
  nnoremap <leader>hu <Cmd>call VSCodeNotify('git.unstageSelectedRanges')<CR>
  nnoremap [c <Cmd>call VSCodeNotify('editor.action.dirtydiff.previous')<CR>
  nnoremap ]c <Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>
  nnoremap [e <Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>
  nnoremap ]e <Cmd>call VSCodeNotify('editor.action.marker.next')<CR>
else
lua << EOF
  require("which-key").setup({}) 
EOF
endif
