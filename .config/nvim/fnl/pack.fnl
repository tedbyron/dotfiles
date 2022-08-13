(import-macros {: packadd! 
                : use-package! 
		: pack 
		: unpack! 
		: call-setup 
		: load-file 
		: load-lang 
		: defer!} :macros)

(packadd! packer.nvim)

(let [packer (require :packer)]
   (packer.init {:git {:clone_timeout 300}
                 :compile_path (.. (vim.fn.stdpath :config) "/lua/packer_compiled.lua")
                 :display {:header_lines 2
                           :title " packer.nvim"
                           :open_fn (λ open_fn []
                                      (local {: float} (require :packer.util))
                                      (float {:border :solid}))}}))

(local conjure-ft [:fennel :clojure :lisp :racket :scheme :rust :janet :lua :guile])
(local treesitter-cmds [:TSInstall
                        :TSBufEnable
                        :TSBufDisable
                        :TSEnable
                        :TSDisable
                        :TSModuleInfo])
(local mason-cmds [:Mason
                   :MasonInstall
                   :MasonInstallAll
                   :MasonUninstall
                   :MasonUninstallAll
                   :MasonLog])

(use-package! :wbthomason/packer.nvim {:opt true})
(use-package! :nvim-lua/plenary.nvim {:module :plenary})
(use-package! :stevearc/profile.nvim {:config (load-file profile)})
(use-package! :rktjmp/hotpot.nvim {:branch :nightly})
(use-package! :eraserhd/parinfer-rust {:opt true :run "cargo build --release"})
(use-package! :Olical/conjure {:branch :develop
                               :ft conjure-ft
                               :config (tset vim.g "conjure#extract#tree_sitter#enabled" true)})
(use-package! :anuvyklack/hydra.nvim {:keys :<space> :config (load-file hydras)})
(use-package! :windwp/nvim-autopairs {:event :InsertEnter :config (load-file autopairs)})
(use-package! :ggandor/leap.nvim {:config (fn []
                                            ((. (require :leap) :set_default_keymaps)))})
(use-package! :kyazdani42/nvim-tree.lua {:cmd :NvimTreeToggle :config (load-file nvimtree)})
(use-package! :nvim-lua/telescope.nvim
              {:cmd :Telescope
               :config (load-file telescope)
               :requires [(pack :nvim-telescope/telescope-project.nvim
                                {:module :telescope._extensions.project})
                          (pack :nvim-telescope/telescope-ui-select.nvim
                                {:module :telescope._extensions.ui-select})
                          (pack :nvim-telescope/telescope-fzf-native.nvim
                                {:module :telescope._extensions.fzf
                                 :run :make})]})
(use-package! :nvim-treesitter/nvim-treesitter
              {:cmd treesitter-cmds
               :run ":TSUpdate"
               :module :nvim-treesitter
               :config (load-file treesitter)
               :requires [(pack :nvim-treesitter/playground {:cmd :TSPlayground})
                          (pack :p00f/nvim-ts-rainbow {:after :nvim-treesitter})
                          (pack :nvim-treesitter/nvim-treesitter-textobjects {:after :nvim-treesitter})]
               :setup (fn []
                        (vim.api.nvim_create_autocmd [:BufRead :BufWinEnter :BufNewFile]
                                 {:group (vim.api.nvim_create_augroup :nvim-treesitter {})
                                  :callback (fn []
                                              (when (fn []
                                                      (local file (vim.fn.expand "%"))
                                                      (and (and (not= file :NvimTree_1)
                                                                (not= file "[packer]"))
                                                           (not= file "")))
                                                (vim.api.nvim_del_augroup_by_name :nvim-treesitter)
                                                ((. (require :packer) :loader) :nvim-treesitter)))}))})
(use-package! :williamboman/mason.nvim {:cmd mason-cmds :config (call-setup mason)})
(use-package! :j-hui/fidget.nvim {:after :nvim-lspconfig :config (call-setup fidget)})
(use-package! :folke/trouble.nvim {:cmd :Trouble :module :trouble :config (call-setup trouble)})
(use-package! "https://git.sr.ht/~whynothugo/lsp_lines.nvim" {:after :nvim-lspconfig :config (call-setup lsp_lines)})
(use-package! :neovim/nvim-lspconfig {:opt true
                                      :setup (defer! nvim-lspconfig)
                                      :config (load-file lsp)})
(use-package! :saecki/crates.nvim {:event ["BufRead Cargo.toml"] :config (call-setup crates)})
(use-package! :simrat39/rust-tools.nvim {:ft :rust :config (load-lang rust)}) 
(use-package! :TimUntersberger/neogit {:config (call-setup neogit) :cmd :Neogit})
(use-package! :lewis6991/gitsigns.nvim {:ft :gitcommit
                                        :config (call-setup gitsigns)
                                        :setup (fn []
                                                  (vim.api.nvim_create_autocmd [:BufRead]
                                                           {:callback (fn []
                                                                        (fn onexit [code _]
                                                                          (when (= code 0)
                                                                            (vim.schedule (fn []
                                                                                            ((. (require :packer) :loader) :gitsigns.nvim)))))

                                                                        (local lines
                                                                               (vim.api.nvim_buf_get_lines 0 0 (- 1) false))
                                                                        (when (not= lines [""])
                                                                          (vim.loop.spawn :git
                                                                                          {:args [:ls-files
                                                                                                  :--error-unmatch
                                                                                                  (vim.fn.expand "%:p:h")]}
                                                                                          onexit)))}))})
(use-package! :hrsh7th/nvim-cmp
              {:config (load-file cmp)
               :after :friendly-snippets
               :requires [(pack :hrsh7th/cmp-path {:after :cmp-buffer})      ;; path completion
                          (pack :hrsh7th/cmp-buffer {:after :cmp-nvim-lsp})  ;; buffer completion
                          (pack :hrsh7th/cmp-nvim-lsp {:after :cmp_luasnip}) ;; lsp completion
                          (pack :hrsh7th/cmp-cmdline {:after :cmp-nvim-lsp}) ;; cmdline completion
                          (pack :PaterJason/cmp-conjure {:after :conjure})   ;; conjure completion
                          (pack :saadparwaiz1/cmp_luasnip {:after :LuaSnip}) ;; snippet completion
                          (pack :rafamadriz/friendly-snippets {:module [:cmp :cmp_nvim_lsp] :event [:InsertEnter :CmdLineEnter]})
                          (pack :L3MON4D3/LuaSnip {:event [:InsertEnter :CmdLineEnter]
                                                   :wants :friendly-snippets
                                                   :config (fn []
                                                             (local {: lazy_load} (require :luasnip/loaders/from_vscode))
                                                             (lazy_load))})]})
(use-package! :kyazdani42/nvim-web-devicons {:module :nvim-web-devicons})
(use-package! :Pocco81/true-zen.nvim {:cmd :TZAtaraxis :config (call-setup truezen)})
; (use-package! :shaunsingh/oxocarbon.nvim {:run :./install.sh})
(use-package! :brenoprata10/nvim-highlight-colors {:cmd :HighlightColorsToggle :config (call-setup nvim-highlight-colors)})
(use-package! :monkoose/matchparen.nvim {:opt true
                                         :setup (defer! matchparen.nvim)
                                         :config (load-file matchparen)})
(use-package! :rcarriga/nvim-notify {:opt true
                                     :setup (fn []
                                              (set vim.notify
                                                   (fn [msg level opts]
                                                     ((. (require :packer) :loader) :nvim-notify)
                                                     (set vim.notify (require :notify))
                                                     (vim.notify msg level opts))))})
(use-package! :nvim-neorg/neorg {:config (load-file neorg) :ft :norg :after :nvim-treesitter})

(unpack!)
