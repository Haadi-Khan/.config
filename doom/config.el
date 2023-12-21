;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; THEME SECTION ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load-theme 'atom-one-dark t)
(setq doom-font (font-spec :family "Recursive Monospace" :size 16)
      doom-variable-pitch-font (font-spec :family "Recursive" :size 16))
(setq doom-symbol-font (font-spec :family "SF Pro"))
(setq display-line-numbers-type 'relative)
(setq-default line-spacing 0.12)
(setq-default tab-width 4) ;; 4 width tabs

(setq highlight-indent-guides-method 'bitmap)
(setq highlight-indent-guides-bitmap-function 'highlight-indent-guides--bitmap-line)
(setq highlight-indent-guides-auto-character-face-perc 50)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; KBD SECTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(map! :leader :desc "List Buffers" :n "b l" #'list-buffers)

(defun haadi/controlu ()
  (evil-scroll-up 0)
  (evil-scroll-line-to-center (line-number-at-pos))
  )
(defun haadi/controld ()
  (evil-scroll-down 0)
  (evil-scroll-line-to-center (line-number-at-pos))
  )
(defun haadi/searchfwd ()
  (evil-search-next)
  (evil-scroll-line-to-center (line-number-at-pos))
  )
(defun haadi/searchprev ()
  (evil-search-previous)
  (evil-scroll-line-to-center (line-number-at-pos))
  )

(map! :map general-override-mode-map
      :n "<C-u>" #'haadi/controlu
      :n "<C-d>" #'haadi/controld
      :desc "Goto mark" :n "M" #'evil-goto-mark
      )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; ORG SECTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-directory "~/org/")

(use-package! org-superstar ; "prettier" bullets
  :hook (org-mode . org-superstar-mode)
  :config
  ;; Make leading stars truly invisible, by rendering them as spaces!
  (setq org-superstar-leading-bullet ?\s
        org-superstar-leading-fallback ?\s
        org-hide-leading-stars nil
        org-superstar-todo-bullet-alist
        '(("TODO" . 9744)
          ("[ ]"  . 9744)
          ("DONE" . 9745)
          ("[X]"  . 9745)))
  )


(use-package! evil-org
  :config
  (custom-set-faces
   '(org-document-title ((t (:inherit outline-1 :height 1.25))))
   '(org-document-info ((t (:inherit outline-1 :height 1.15))))
   '(org-level-1 ((t (:inherit outline-1 :height 1.15))))
   '(org-level-2 ((t (:inherit outline-2 :height 1.125))))
   '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
   '(org-level-4 ((t (:inherit outline-4 :height 1.075))))
   '(org-level-5 ((t (:inherit outline-5 :height 1.05))))
   )
  ;; (add-hook 'org-mode-hook 'org-fragtog-mode)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.6))
  )

;; Automatic bulleting
(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable)
  )
(add-hook 'org-mode-hook
          (lambda () (org-autolist-mode)))

(add-hook 'org-mode org-cdlatex-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; LaTeX SECTION ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'LaTeX-mode-hook #'turn-on-cdlatex)
(add-hook 'LaTeX-mode-hook #'preview-buffer)

(defun my-yas-try-expanding-auto-snippets ()
  (when (and (boundp 'yas-minor-mode) yas-minor-mode)
    (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
      (yas-expand))))

(add-hook 'post-self-insert-hook #'my-yas-try-expanding-auto-snippets)
(remove-hook 'org-mode-hook #'company-mode)

(map! :leader :desc "Preview TeX" :n "v p" #'org-latex-preview)
(map! :leader :desc "Edit TeX" :n "v h" #'org-edit-latex-fragment)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; RSS SECTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; CODE SECTION ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq company-idle-delay 0.01)
(setq gc-cons-threshold 200000000) ;; 200mb
(setq read-process-output-max (* 4096 4096)) ;; 4mb
(setq lsp-idle-delay 0.500)
(setq lsp-log-io nil) ; if set to true can cause a performance hit

(setq company-idle-delay 0.25)

(use-package dap-mode
  :ensure
  :config
  (dap-ui-mode)
  (dap-ui-controls-mode 1)

  ;; (require 'dap-lldb)
  ;;;;;(require 'dap-cpptools)
  ;; (require 'dap-gdb-lldb)
  ;; installs .extension/vscode
  ;; (dap-gdb-lldb-setup)
  (dap-cpptools-setup)
  (dap-register-debug-template "Rust::CppTools Run Configuration"
                               (list :type "cppdbg"
                                     :request "launch"
                                     :name "Rust::Run"
                                     :MIMode "gdb"
                                     :miDebuggerPath "rust-gdb"
                                     :environment []
                                     :program "${workspaceFolder}/target/debug/REPLACETHIS"
                                     :cwd "${workspaceFolder}"
                                     :console "external"
                                     :dap-compilation "cargo build"
                                     :dap-compilation-dir "${workspaceFolder}")))

(with-eval-after-load 'dap-mode
  (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  (dap-auto-configure-mode +1))
