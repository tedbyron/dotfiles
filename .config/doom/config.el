;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(global-subword-mode t)
(display-time-mode t)
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode 1))
(menu-bar-mode -1)
(global-display-fill-column-indicator-mode t) ; TODO: only in main buffer/avoid minibuffer

(custom-set-faces!
  `('fill-column-indicator :foreground ,(doom-color 'base3))
  `('hl-line :background ,(doom-color 'base3)))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 120))

(map! :desc "Frame maximized" :leader "t M" #'toggle-frame-maximized)

(setq-default major-mode 'org-mode
              delete-by-moving-to-trash t
              window-combination-resize t)

(setq user-full-name "Teddy Byron"
      user-mail-address "ted@tedbyron.com"
      password-cache-expiry 60

      ;; buffer
      scroll-margin 3
      display-line-numbers-type 'visual
      x-stretch-cursor t
      truncate-string-ellipsis "…"

      ;; modeline
      display-time-24hr-format t
      ;; display-time-default-load-average nil

      ;; doom
      doom-theme 'doom-dracula
      ;; doom-themes-treemacs-theme "doom-colors"
      doom-font (font-spec :family "Curlio" :size 14 :weight 'normal)

      ;; evil mode
      evil-want-fine-undo t
      evil-split-window-below t
      evil-vsplit-window-right t

      ;; org mode
      org-directory "~/org/"
      org-ellipsis "…"

      ;; miscellaneous
      all-the-icons-scale-factor 1.0
      projectile-project-search-path '("~/git/")
      which-key-idle-delay 0.75)

;; (remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-mode-hook
  (hide-mode-line-mode 1)
  (hl-line-mode -1))
;; (setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

(after! org
  (setq doom-modeline-enable-word-count t))
