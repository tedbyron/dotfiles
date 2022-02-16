;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(global-subword-mode t)
(display-time-mode t)
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode 1))

(setq-default major-mode 'org-mode
              delete-by-moving-to-trash t
              window-combination-resize t)

(setq user-full-name "Teddy Byron"
      user-mail-address "ted@tedbyron.com"

      password-cache-expiry 60

      ;; Editor
      scroll-margin 3
      display-line-numbers-type 'visual
      x-stretch-cursor t
      truncate-string-ellipsis "…"

      ;; Modeline
      display-time-24hr-format t
      ;; display-time-default-load-average nil

      ;; Doom
      doom-theme 'doom-dracula
      doom-font "-*-Iosevka SS06-*-*-expanded-*-14-*-*-*-m-0-iso10646-1"
      doom-serif-font "-*-Iosevka Etoile-*-*-normal-*-14-*-*-*-p-0-iso10646-1"
      doom-variable-pitch-font "-*-Iosevka Aile-*-*-normal-*-14-*-*-*-p-0-iso10646-1"

      ;; Org mode
      org-directory "~/org/"
      org-ellipsis "…"

      ;; Evil mode
      evil-want-fine-undo t
      evil-split-window-below t
      evil-vsplit-window-right t

      ;; Plugins
      projectile-project-search-path '("~/git/"))

;; Frame size
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 120))
(map! :desc "Frame maximized" :leader "t M" 'toggle-frame-maximized)
