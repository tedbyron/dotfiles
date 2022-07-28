;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(display-time-mode -1)
(global-display-fill-column-indicator-mode t)
(global-subword-mode t)
(menu-bar-mode -1)
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode 1))

(setq-default delete-by-moving-to-trash t
              fill-column 100
              window-combination-resize t
              x-stretch-cursor t)

(setq all-the-icons-scale-factor 1.0
      auto-save-default t
      ;; centaur-tabs-icon-scale-factor 0.8
      centaur-tabs-show-new-tab-button nil
      centaur-tabs-left-edge-margin nil
      centaur-tabs-right-edge-margin nil
      centaur-tabs-set-bar 'over
      centaur-tabs-set-close-button nil
      display-line-numbers-type 'visual
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

(add-hook! '+doom-dashboard-mode-hook 'centaur-tabs-local-mode)
(add-hook! calendar-mode 'centaur-tabs-local-mode)
(add-hook! dired-mode 'centaur-tabs-local-mode)
(add-hook! ibuffer-mode 'centaur-tabs-local-mode)
(add-hook! org-agenda-mode 'centaur-tabs-local-mode)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 120))

(after! org
  (setq doom-modeline-enable-word-count t))

(custom-set-faces!
  `('fill-column-indicator :foreground ,(doom-color 'base3))
  `('hl-line :background ,(doom-color 'base3)))

(map! :desc "Frame maximized" :leader "t M" #'toggle-frame-maximized)
(map! :map evil-window-map "SPC" #'evil-window-rotate-downwards)
