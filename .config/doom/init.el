;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

(doom! :input
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       (company +childframe)
       ;;helm
       ;;ido
       ;;ivy
       (vertico +icons)

       :ui
       ;;deft
       doom
       doom-dashboard
       doom-quit
       ;;(emoji +unicode)
       hl-todo
       ;;hydra
       ;;indent-guides
       (ligatures +iosevka)
       ;;minimap
       modeline
       nav-flash
       ;;neotree
       ophints
       (popup
        +all
        +defaults)
       ;;tabs
       (treemacs +lsp)
       ;;unicode
       vc-gutter
       ;;vi-tilde-fringe
       (window-select +numbers)
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       ;;god
       ;;lispy
       multiple-cursors
       ;;objed
       ;;parinfer
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
       ;;eshell
       ;;shell
       ;;term
       vterm

       :checkers
       syntax
       ;;(spell +everywhere)
       ;;grammar

       :tools
       ;;ansible
       ;;biblio
       (debugger +lsp)
       ;;direnv
       ;;docker
       ;;editorconfig
       ;;ein
       (eval +overlay)
       ;;gist
       lookup
       (lsp +peek)
       (magit +forge)
       ;;make
       ;;pass
       pdf
       ;;prodigy
       rgb
       ;;taskrunner
       ;;terraform
       ;;tmux
       upload

       :os
       (:if IS-MAC macos)
       tty

       :lang
       ;;agda
       ;;beancount
       ;;cc
       ;;clojure
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       data
       ;;(dart +flutter +lsp)
       ;;dhall
       ;;(elixir +lsp)
       ;;elm
       emacs-lisp
       ;;(erlang +lsp)
       ;;ess
       ;;factor
       ;;faust
       ;;fortran
       ;;fsharp
       ;;fstar
       ;;gdscript
       ;;(go +lsp)
       ;;(haskell +lsp)
       ;;hy
       ;;idris
       (json +lsp)
       ;;(java +lsp)
       (javascript +lsp)
       ;;julia
       ;;kotlin
       ;;latex
       ;;lean
       ;;ledger
       ;;lua
       markdown
       ;;nim
       ;;nix
       ;;ocaml
       (org
        +pretty
        +dragndrop
        +pandoc
        +present
        +roam2)
       ;;php
       ;;plantuml
       ;;purescript
       ;;python
       ;;qt
       ;;racket
       ;;raku
       ;;rest
       ;;rst
       ;;(ruby +rails)
       (rust +lsp)
       ;;scala
       ;;(scheme +guile)
       sh
       ;;sml
       ;;solidity
       ;;swift
       ;;terra
       (web +lsp)
       (yaml +lsp)
       ;;zig

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere
       ;;irc
       ;;(rss +org)
       ;;twitter

       :config
       ;;literate
       (default
         +bindings
         +smartparens))
