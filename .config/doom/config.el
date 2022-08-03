;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 120))

(+global-word-wrap-mode)
(display-time-mode -1) ; TODO: display time in fullscreen
(global-subword-mode)
(global-whitespace-mode)
(lsp-treemacs-sync-mode)
(treemacs-follow-mode)
(treemacs-project-follow-mode)

(when (and (display-graphic-p))
  (ns-set-resource nil "ApplePressAndHoldEnabled" "NO")
  (setq ns-use-proxy-icon nil))
(unless IS-MAC (menu-bar-mode -1))
;; TODO: display battery in fullscreen
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode t))

(setq-default comment-column 0
              fill-column 100)

(setq +word-wrap-extra-indent nil
      +zen-text-scale 0
      all-the-icons-scale-factor 1.0
      auto-save-default t
      comment-auto-fill-only-comments t
      company-box-doc-delay 0.2
      company-selection-wrap-around t
      delete-by-moving-to-trash t
      display-line-numbers-type 'relative
      display-time-24hr-format t
      display-time-default-load-average nil
      doom-font (font-spec :family "Curlio" :size 14.0 :weight 'normal)
      doom-modeline-buffer-modification-icon nil
      doom-modeline-github t
      doom-modeline-icon nil
      doom-modeline-major-mode-icon t
      doom-modeline-percent-position nil
      doom-scratch-initial-major-mode #'lisp-interaction-mode
      doom-theme 'doom-dracula
      doom-themes-treemacs-enable-variable-pitch nil
      doom-themes-treemacs-theme "doom-colors"
      evil-ex-substitute-global t
      evil-split-window-below t
      evil-vsplit-window-right t
      evil-want-fine-undo t
      frame-title-format 'invocation-name
      org-directory "~/org"
      org-ellipsis "…"
      password-cache-expiry 120
      projectile-project-search-path '("~/git")
      scroll-margin 3
      truncate-string-ellipsis "…"
      undo-limit 64000000
      user-full-name "Teddy Byron"
      user-mail-address "ted@tedbyron.com"
      which-key-idle-delay 0.5
      whitespace-line-column nil
      whitespace-style '(face trailing tabs spaces lines-tail empty)
      window-combination-resize t
      writeroom-width 100
      x-stretch-cursor t)

(setq-hook! '(c-or-c++-mode-hook emacs-lisp-mode-hook sh-mode-hook)
  fill-column 80)
;; (setq-hook! 'prog-mode-hook
;;   comment-column 0) ; FIXME: figure out why setq-default not working
(setq-hook! 'text-mode-hook
  comment-auto-fill-only-comments nil)

(add-hook 'doom-project-hook #'treemacs-display-current-project-exclusively)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(add-hook! (prog-mode text-mode) #'auto-fill-mode)

(after! lsp-mode
  (setq lsp-auto-guess-root t
        lsp-enable-on-type-formatting t
        lsp-enable-relative-indentation t
        lsp-headerline-breadcrumb-enable nil
        lsp-headerline-breadcrumb-icons-enable nil
        lsp-semantic-tokens-enable t))
(after! lsp-ui
  (setq lsp-ui-doc-delay 0.2))

(custom-set-faces!
  `('doom-modeline-buffer-modified :foreground ,(doom-color 'yellow))
  `('doom-modeline-project-dir :foreground ,(doom-color 'green))
  `('fill-column-indicator :foreground ,(doom-color 'base3))
  `('hl-line :background ,(doom-color 'base3)))

(map! :leader
      :desc "M-x"             ";" #'execute-extended-command
      :desc "Eval expression" ":" #'pp-eval-expression
      :desc "Dashboard"       "d" #'+doom-dashboard/open)
(map! :map doom-leader-toggle-map
      :desc "Frame maximized" "M" #'toggle-frame-maximized)

(defvar required-fonts '("Curlio") "Fonts required to load this config.")
(defvar available-fonts
  (delete-dups (or (font-family-list)
                   (split-string (shell-command-to-string "fc-list : family")
                                 "[,\n]")))
  "Fonts installed on the system.")
(defvar missing-fonts
  (delq nil (mapcar
             (lambda (font)
               (unless (delq nil (mapcar (lambda (f)
                                           (string-match-p (format "^%s$" font)
                                                           f))
                                         available-fonts))
                 font))
             required-fonts))
  "Fonts missing from `required-fonts'.")
(when missing-fonts
  (pp-to-string
   `(unless noninteractive
      (add-hook! 'doom-init-ui-hook
        (run-at-time
         nil nil
         (lambda ()
           (message "%s missing the following fonts: %s"
                    (propertize "Warning:" 'face '(bold warning))
                    (mapconcat (lambda (font)
                                 (propertize font 'face
                                             'font-lock-variable-name-face))
                               ',missing-fonts
                               ", "))
           (sleep-for 0.5)))))))

(defun doom-modeline-conditional-buffer-encoding ()
  "Conditionally show buffer file encoding or line ending type."
  (setq-local doom-modeline-buffer-encoding
              (unless (and
                       (memq (plist-get
                              (coding-system-plist buffer-file-coding-system)
                              :category)
                             '(coding-category-undecided coding-category-utf-8))
                       (not (memq (coding-system-eol-type
                                   buffer-file-coding-system) '(1 2))))
                t)))
(add-hook 'after-change-major-mode-hook
          #'doom-modeline-conditional-buffer-encoding)

(defun +doom-dashboard-setup-modified-keymap ()
  "Set up a keymap for faster navigation from the dashboard."
  (setq +doom-dashboard-mode-map (make-sparse-keymap))
  (map! :map +doom-dashboard-mode-map
        :desc "Find file"
        :ne "f" #'find-file
        :desc "Recent files"
        :ne "r" #'consult-recent-file
        :desc "Notes"
        :ne "n" #'org-roam-node-find
        :desc "Agenda"
        :ne "a" #'org-agenda
        :desc "Switch workspace buffer"
        :ne "b" #'+vertico/switch-workspace-buffer
        :desc "Switch buffer"
        :ne "B" #'consult-buffer
        :desc "Ibuffer"
        :ne "i" #'ibuffer
        :desc "Previous buffer"
        :ne "q" #'previous-buffer
        :desc "Restore last session"
        :ne "R" #'doom/quickload-session
        :desc "Open private configuration"
        :ne "c" #'doom/open-private-config
        ;; :desc "Open literate configuration"
        ;; :ne "C" (cmd! (find-file
        ;;                (expand-file-name "config.org" doom-private-dir)))
        :desc "Find dotfile"
        :ne "." (cmd! (doom-project-find-file "~/git/dotfiles"))
        ;; :desc "Dashboard keymap"
        ;; :ne "h" (cmd! (which-key-show-keymap '+doom-dashboard-mode-map))
        :desc "Quit"
        :ne "Q" #'save-buffers-kill-terminal))
(add-hook! 'doom-init-ui-hook (+doom-dashboard-setup-modified-keymap))
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor '(nil))
(remove-hook! '+doom-dashboard-functions
  #'doom-dashboard-widget-shortmenu
  #'doom-dashboard-widget-loaded
  #'doom-dashboard-widget-footer)

(defun sort-words (reverse beg end)
  "Sort words in region aphabetically, argument means descending order.
Prefixed with negative \\[universal-argument], sorts in reverse.

The variable `sort-fold-case' determines whether alphabetic case
affects the sort order.

See `sort-regexp-fields'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\w+" "\\&" beg end))

(defun reverse-words (beg end)
  "Reverse the order of words in region."
  (interactive "*r")
  (apply 'insert
         (reverse
          (split-string (delete-and-extract-region beg end)
                        "\\b"))))

(defun sort-symbols (reverse beg end)
  "Sort symbols in region alphabetically, argument means descending order.
Prefixed with negative \\[universal-argument], sorts in reverse.

The variable `sort-fold-case' determines whether alphabetic case
affects the sort order.

See `sort-regexp-fields'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\(\\sw\\|\\s_\\)+" "\\&" beg end))
