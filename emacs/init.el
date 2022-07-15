(require 'org)
(org-babel-load-file
 (expand-file-name  "config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-want-C-u-scroll t)
 '(org-src-preserve-indentation nil)
 '(package-selected-packages
   '(google-translate-default-ui nlinum-relative good-scroll rust-mode rainbow-delimiters dart-server lsp-dart haskell-mode origami dap-python ein jupyter ranger org-roam erc-image bitlbee tree-sitter-langs tree-sitter langtool pomodoro lsp-origami python-mode yasnippet xah-fly-keys writeroom-mode which-key vterm use-package undo-tree treemacs-evil toc-org sudo-edit subed smex real-auto-save pyvenv projectile perspective peep-dired org-superstar org-fragtog org-evil org-edit-latex org-bullets one-themes neotree modern-cpp-font-lock magit lsp-ui lsp-python-ms lsp-pyright lsp-java key-chord ivy-rich ivy-posframe highlight-indent-guides helm-lsp google-translate general gcmh flyspell-popup flycheck fill-column-indicator evil-tutor evil-org evil-collection eshell-syntax-highlighting emojify elfeed-goodies doom-modeline dired-open dashboard counsel company clang-format+ centaur-tabs ccls atom-one-dark-theme all-the-icons-dired))
 '(warning-suppress-types '((org-roam) (org-roam) (use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-info ((t (:inherit outline-1 :height 1.15))))
 '(org-document-title ((t (:inherit outline-1 :height 1.25))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.15))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.125))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.075))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.05)))))
