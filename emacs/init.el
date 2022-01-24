(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(highlight-indent-guides flyspell-popup centaur-tabs lsp-java markdown-mode magit LaTeX-mode writeroom-mode perspective neotree evil-tutor elfeed-goodies sudo-edit ox-man dired smex org-tempo all-the-icons-dired which-key vterm use-package toc-org projectile peep-dired org-bullets magit-todos magit-lfs ivy-rich ivy-posframe haskell-mode general evil-collection eshell-syntax-highlighting doom-themes doom-modeline dired-open dashboard counsel))
 '(persp-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.15))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.125))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.075))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.05)))))
