(require 'org)
(org-babel-load-file
 (expand-file-name  "config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(warning-suppress-types '((use-package) (use-package))))
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
