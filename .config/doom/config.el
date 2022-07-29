;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(+global-word-wrap-mode 1)
(display-time-mode -1)
(global-display-fill-column-indicator-mode t)
(global-subword-mode t)
(menu-bar-mode -1)
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode 1))

(delq! t custom-theme-load-path)

(setq-default delete-by-moving-to-trash t
              fill-column 100
              window-combination-resize t
              x-stretch-cursor t)

(setq +word-wrap-extra-indent nil
      all-the-icons-scale-factor 1.0
      auto-save-default t
      centaur-tabs-height 26
      centaur-tabs-icon-scale-factor 0.8
      centaur-tabs-show-new-tab-button nil
      centaur-tabs-set-bar 'over
      centaur-tabs-set-close-button nil
      display-line-numbers-type 'relative
      display-time-24hr-format t
      display-time-default-load-average nil
      doom-font (font-spec :family "Curlio Nerd Font Mono" :size 14 :weight 'normal)
      doom-theme 'doom-dracula
      evil-split-window-below t
      evil-vsplit-window-right t
      evil-want-fine-undo t
      org-directory "~/org"
      org-ellipsis "…"
      password-cache-expiry 120
      projectile-project-search-path '("~/git")
      scroll-margin 3
      truncate-string-ellipsis "…"
      undo-limit 64000000
      user-full-name "Teddy Byron"
      user-mail-address "ted@tedbyron.com"
      which-key-idle-delay 0.5)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 120))

(custom-set-faces!
  `('doom-modeline-buffer-modified :foreground ,(doom-color 'yellow))
  `('doom-modeline-project-dir :foreground ,(doom-color 'green))
  `('fill-column-indicator :foreground ,(doom-color 'base3))
  `('hl-line :background ,(doom-color 'base3)))

(map! :map doom-leader-map "d" #'+doom-dashboard/open)
(map! :map doom-leader-toggle-map "M" #'toggle-frame-maximized)
(map! :map evil-window-map "SPC" #'evil-window-rotate-downwards)

(after! org
  (setq doom-modeline-enable-word-count t))

(use-package! centaur-tabs
  :hook
  (Info-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (dired-mode . centaur-tabs-local-mode)
  (fundamental-mode . centaur-tabs-local-mode)
  (ibuffer-mode . centaur-tabs-local-mode))

(defvar required-fonts '("Curlio Nerd Font Mono"))
(defvar available-fonts
  (delete-dups (or (font-family-list)
                   (split-string (shell-command-to-string "fc-list : family")
                                 "[,\n]"))))
(defvar missing-fonts
  (delq nil (mapcar
             (lambda (font)
               (unless (delq nil (mapcar (lambda (f)
                                           (string-match-p (format "^%s$" font) f))
                                         available-fonts))
                 font))
             required-fonts)))
(if missing-fonts
    (pp-to-string
     `(unless noninteractive
        (add-hook! 'doom-init-ui-hook
          (run-at-time nil nil
                       (lambda ()
                         (message "%s missing the following fonts: %s"
                                  (propertize "Warning:" 'face '(bold warning))
                                  (mapconcat (lambda (font) (propertize font 'face 'font-lock-variable-name-face))
                                             ',missing-fonts
                                             ", "))
                         (sleep-for 0.5))))))
  ";; No missing fonts")

(defun doom-modeline-conditional-buffer-encoding ()
  "Only show the modeline when encoding is not UTF-8 or line endings are not LF"
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))
(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

(defun +doom-dashboard-setup-modified-keymap ()
  (setq +doom-dashboard-mode-map (make-sparse-keymap))
  (map! :map +doom-dashboard-mode-map
        :desc "Find file" :ne "f" #'find-file
        :desc "Recent files" :ne "r" #'consult-recent-file
        :desc "Notes" :ne "n" #'org-roam-node-find
        :desc "Agenda" :ne "a" #'org-agenda
        :desc "Switch workspace buffer" :ne "b" #'+vertico/switch-workspace-buffer
        :desc "Switch buffer" :ne "B" #'consult-buffer
        :desc "Ibuffer" :ne "i" #'ibuffer
        :desc "Previous buffer" :ne "p" #'previous-buffer
        :desc "Restore last session" :ne "R" #'doom/quickload-session
        :desc "Open private configuration" :ne "c" #'doom/open-private-config
        ;; :desc "Open literate configuration" :ne "C" (cmd! (find-file (expand-file-name "config.org" doom-private-dir)))
        :desc "Find dotfile" :ne "." (cmd! (doom-project-find-file "~/git/dotfiles"))
        ;; :desc "Dashboard keymap" :ne "h" (cmd! (which-key-show-keymap '+doom-dashboard-mode-map))
        :desc "Quit" :ne "Q" #'save-buffers-kill-terminal))
(add-transient-hook! #'+doom-dashboard-mode (+doom-dashboard-setup-modified-keymap))
(add-transient-hook! #'+doom-dashboard-mode :append (+doom-dashboard-setup-modified-keymap))
(add-hook! 'doom-init-ui-hook :append (+doom-dashboard-setup-modified-keymap))
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
