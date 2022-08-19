(let [compiled? (= (vim.fn.filereadable (.. (vim.fn.stdpath :config) "/lua/packer_compiled.lua")) 1)
      load-compiled #(require :packer_compiled)]
 (if compiled?
   (load-compiled)
   (do
     (require :pack)
     (. (require :packer) :sync))))

(set vim.env.PATH (.. vim.env.PATH
                      ":"
                      (vim.fn.stdpath :data)
                      :/mason/bin))

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
