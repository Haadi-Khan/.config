(load "~/.emacs.d/evil")

; Theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/plugins/one-dark/")
(load-theme 'atom-one-dark t)

; Basic setup crap
(global-undo-tree-mode)
(setq undo-tree-auto-save-history t)
(setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
