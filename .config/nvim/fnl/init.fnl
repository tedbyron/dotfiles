(let [built-ins [:gzip
                 :zip
                 :zipPlugin
                 :tar
                 :tarPlugin
                 :getscript
                 :getscriptPlugin
                 :vimball
                 :vimballPlugin
                 :2html_plugin
                 :matchit
                 :matchparen
                 :logiPat
                 :rrhelper
                 :netrw
                 :netrwPlugin
                 :netrwSettings
                 :netrwFileHandlers]
      providers [:perl :node :ruby :python :python3]]
  (each [_ v (ipairs built-ins)]
    (let [plugin (.. :loaded_ v)]
      (tset vim.g plugin 1)))
  (each [_ v (ipairs providers)]
    (let [provider (.. :loaded_ v :_provider)]
      (tset vim.g provider 0))))

(import-macros {: augroup!
                : autocmd!
                : colorscheme
                : command!
		: let!
		: map!
                : set!
                } :macros)

(let [compiled? (= (vim.fn.filereadable (.. (vim.fn.stdpath :config) "/lua/packer_compiled.lua")) 1)
      load-compiled #(require :packer_compiled)]
 (if compiled?
   (load-compiled)
   (do
     (require :pack)
     (. (require :packer) :sync))))

(set vim.env.PATH (.. vim.env.PATH ":" (vim.fn.stdpath :data) :/mason/bin))

(set! updatetime 200)
(set! timeoutlen 500)
(set! shortmess :aoOstTIcF)
(set! list)
(set! listchars {:tab "> " :nbsp "␣" :trail "-"})
(set! clipboard :unnamedplus)
(set! mouse :a)
(set! undofile)
(set! noswapfile)
(set! rulerformat "%14(%l,%c%V%)")
(set! noshowmode)
(set! laststatus 3)
(set! cmdheight 1)
(set! number)
(set! relativenumber)
(set! smartcase)
(set! copyindent)
(set! smartindent)
(set! preserveindent)
(set! tabstop 4)
(set! shiftwidth 4)
(set! softtabstop 4)
(set! expandtab)
(set! cursorline)
(set! splitright)
(set! splitbelow)
(set! scrolloff 3)
(set! completeopt [:menu :menuone :preview :noinsert])
(set! background :dark)
(set! guifont "Curlio:h14")
; (colorscheme )

(let! mapleader " ")
(let! maplocalleader " m")

(map! [n] "<esc>" "<esc><cmd>noh<cr>")

(map! [n] ";" ":")

(map! [n] "<leader><space>" "<cmd>Telescope find_files<CR>")
(map! [n] "<leader>bb" "<cmd>Telescope buffers<CR>")
(map! [n] "<leader>:" "<cmd>Telescope commands<CR>")

(command! Scratch "new | setlocal bt=nofile bh=wipe nobl noswapfile")
(command! SetScratch "edit [Scratch] | setlocal bt=nofile bh=wipe nobl noswapfile")

(command! PackerSync "lua require 'pack' require('packer').sync()")
(command! PackerStatus "lua require 'pack' require('packer').status()")
(command! PackerInstall "lua require 'pack' require('packer').install()")
(command! PackerUpdate "lua require 'pack' require('packer').update()")
(command! PackerCompile "lua require 'pack' require('packer').compile()")

(augroup! restore-cursor-on-exit
          (autocmd! VimLeave * '(set! guicursor ["a:ver100-blinkon0"])))
(augroup! parinfer
          (autocmd! InsertEnter * '(require :pack.parinfer)))

(require :statusline)
