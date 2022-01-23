(setq user-full-name "Haadi Khan"
      user-mail-address "haadikhan05@gmail.com")

(menu-bar-mode 1)
(setq doom-theme 'doom-one)
(setq display-line-numbers-type 'relative)
(require 'fill-column-indicator)
(setq-default fill-column-indicator '(foreground-color . "#E0DFDB"))
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(setq doom-font (font-spec :family "Roboto Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Roboto Mono" :size 16)
      doom-big-font (font-spec :family "Roboto Mono" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(setq global-prettify-symbols-mode t)

(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)

(after! org
  (setq org-directory "~/org/"
        org-ellipsis " ⌄ "
        org-log-done 'time
        org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]

        org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
          '((sequence
             "TODO(t)"
             "APUSH(a)"
             "STAT(s)"
             "PHYSICS(P)"
             "CALC(C)"
             "LANG(l)"
             "MULTI(m)"
             "CS(S)"
             "ROBOTICS(r)"
             "SCIOLY(S)"
             "|"
             "DONE(d)"
             "CANCELLED(c)"
             "|"
             "PROG(p)"))
          )
        (custom-set-faces
        '(org-level-1 ((t (:inherit outline-1 :height 1.15))))
        '(org-level-2 ((t (:inherit outline-2 :height 1.125))))
        '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
        '(org-level-4 ((t (:inherit outline-4 :height 1.075))))
        '(org-level-5 ((t (:inherit outline-5 :height 1.05))))
        )
  )
(add-hook 'org-mode-hook 'flyspell-mode)

;;(define-key dired-mode-map "a" 'find-file)

;; (require 'guess-language)
;; (use-package guess-language         ; Automatically detect language for Flyspell
  ;; :ensure t
  ;; :defer t
  ;; ;; :init (add-hook 'text-mode-hook #'guess-language-mode)
  ;; :config
  ;; (setq guess-language-langcodes '((en . ("en_US" "English"))
                                   ;; (es . ("es_ES" "Spanish")))
        ;; guess-language-languages '(en es)
        ;; guess-language-min-paragraph-length 45)
  ;; :diminish guess-language-mode)
(add-hook 'text-mode-hook 'flyspell-mode)
(setq ispell-program-name "hunspell")

(map! :leader
      (:prefix ("-" . "open file")
       :desc "Edit Todos" "d" #'(lambda () (interactive) (find-file "~/org/todos.org"))))
