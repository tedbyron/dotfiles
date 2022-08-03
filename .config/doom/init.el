;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

(doom! ;; :input
       ;; chinese
       ;; japanese
       ;; layout

       :completion
       (company +childframe)
       ;; helm
       ;; ido
       ;; ivy
       (vertico +icons)

       :ui
       ;; deft
       doom
       doom-dashboard
       doom-quit
       ;; (emoji +unicode)
       hl-todo
       ;; hydra
       ;; indent-guides
       ligatures
       ;; minimap
       modeline
       nav-flash
       ;; neotree
       ophints
       (popup
        +all
        +defaults)
       ;; tabs
       (treemacs +lsp)
       ;; unicode
       vc-gutter
       ;; vi-tilde-fringe
       (window-select +numbers)
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       ;; god
       ;; lispy
       multiple-cursors
       ;; objed
       ;; parinfer
       rotate-text
       snippets
       word-wrap

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       ;; eshell
       ;; shell
       ;; term
       ;; vterm

       :checkers
       (syntax +childframe)
       (spell +aspell)
       grammar

       :tools
       ;; ansible
       ;; biblio
       (debugger +lsp)
       ;; direnv
       (docker +lsp)
       ;; editorconfig
       ;; ein
       (eval +overlay)
       gist
       (lookup
        +dictionary
        +docsets
        ;; +offline
        )
       (lsp +peek)
       (magit +forge)
       ;; make
       ;; (pass +auth)
       pdf
       ;; prodigy
       rgb
       ;; taskrunner
       terraform
       ;; tmux
       ;; upload

       :os
       (:if IS-MAC macos)
       (tty +osc)

       :lang
       ;; agda
       ;; beancount
       ;; (cc +lsp)
       ;; (clojure +lsp)
       ;; common-lisp
       ;; coq
       ;; crystal
       ;; (csharp +lsp +unity)
       ;; (dart +flutter +lsp)
       data
       ;; dhall
       ;; (elixir +lsp)
       ;; (elm +lsp)
       emacs-lisp
       ;; (erlang +lsp)
       ;; (ess +stan)
       ;; factor
       ;; faust
       ;; fortran
       ;; (fsharp +lsp)
       ;; fstar
       ;; (gdscript +lsp)
       ;; (go +lsp)
       ;; (haskell +lsp)
       ;; hy
       ;; idris
       ;; (java +lsp +meghanada)
       (javascript +lsp)
       (json +lsp)
       ;; (julia +lsp)
       ;; (kotlin +lsp)
       ;; (latex +cdlatex +fold +latexmk +lsp)
       ;; lean
       ;; ledger
       ;; (lua +fennel +lsp +moonscript)
       (markdown +grip)
       ;; nim
       ;; nix
       ;; (ocaml +lsp)
       (org
        ;; +brain
        +dragndrop
        ;; +gnuplot
        ;; +hugo
        ;; +ipython
        ;; +journal
        ;; +jupyter
        ;; +noter
        +pandoc
        ;; +pomodoro
        +present
        +pretty
        ;; +roam
        +roam2)
       ;; (php +hack +lsp)
       ;; plantuml
       ;; (purescript +lsp)
       ;; (python +conda +cython +lsp +poetry +pyenv +pyright)
       ;; qt
       ;; (racket +lsp +xp)
       ;; raku
       ;; rest
       ;; rst
       ;; (ruby +chruby +lsp +rails +rbenv +rvm)
       (rust +lsp)
       ;; (scala +lsp)
       ;; (scheme +chez +chibi +chicken +gambit +gauche +guile +kawa +mit +racket)
       (sh
        ;; +fish
        ;; +lsp
        ;; +powershell
        )
       ;; sml
       ;; solidity
       ;; (swift +lsp)
       ;; terra
       (web +lsp)
       (yaml +lsp)
       ;; (zig +lsp)

       :email
       ;; (mu4e +org +gmail)
       ;; notmuch
       ;; (wanderlust +gmail)

       :app
       ;; calendar
       ;; emms
       ;; everywhere
       ;; irc
       ;; (rss +org)
       ;; twitter

       :config
       ;; literate
       (default
         +bindings
         +smartparens))
