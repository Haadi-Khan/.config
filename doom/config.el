;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; THEME SECTION ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'default-frame-alist '(undecorated-round . t))
(load-theme 'atom-one-dark t)
(setq doom-font (font-spec :family "Recursive Monospace" :size 16 :weight 'regular) doom-variable-pitch-font (font-spec :family "Recursive" :size 16 :weight 'regular))
(setq doom-symbol-font (font-spec :family "SF Pro" ))
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
  )

;; Automatic bulleting
(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable)
  )
(add-hook 'org-mode-hook
          (lambda () (org-autolist-mode)))

(add-hook 'org-mode org-cdlatex-mode)

(setq org-hide-emphasis-markers t)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; DEV SECTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold 400000000) ;; 400mb
(setq read-process-output-max (* 8192 1024)) ;; 4mb
(setq company-minimum-prefix-length 1)
(setq lsp-idle-delay 0.1)
(setq lsp-log-io nil) ; if set to true can cause a performance hit

(setq lsp-completion-show-kind t)


(add-hook 'prog-mode-hook 'real-auto-save-mode)
(setq real-auto-save-interval 3) ;; in seconds

(setq company-idle-delay 0.01)

;; (use-package dap-mode
;;   :ensure
;;   :config
;;   (dap-mode 1)

;;   ;; installs .extension/vscode
;;   (dap-register-debug-template "Rust::CppTools Run Configuration"
;;                                (list :type "cppdbg"
;;                                      :request "launch"
;;                                      :name "Rust::Run"
;;                                      :MIMode "gdb"
;;                                      :miDebuggerPath "rust-gdb"
;;                                      :environment []
;;                                      :program "${workspaceFolder}/target/debug/REPLACETHIS"
;;                                      :cwd "${workspaceFolder}"
;;                                      :console "external"
;;                                      :dap-compilation "cargo build"
;;                                      :dap-compilation-dir "${workspaceFolder}")))

;; (with-eval-after-load 'dap-mode
;;   (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
;;   (dap-auto-configure-mode +1))
(after! rustic
  (setq rustic-format-on-save nil))

(map! :leader :desc "Toggle Breakpoint" :n "c b" #'dap-breakpoint-toggle)

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(map! :leader :desc "Toggle copilot" :n "c g" #'copilot-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; TEX SECTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AucTeX settings - almost no changes
(use-package latex
  :ensure auctex
  :hook ((LaTeX-mode . prettify-symbols-mode))
  :bind (:map LaTeX-mode-map
              ("C-S-e" . latex-math-from-calc))
  :config
  ;; Format math as a Latex string with Calc
  (defun latex-math-from-calc ()
    "Evaluate `calc' on the contents of line at point."
    (interactive)
    (cond ((region-active-p)
           (let* ((beg (region-beginning))
                  (end (region-end))
                  (string (buffer-substring-no-properties beg end)))
             (kill-region beg end)
             (insert (calc-eval `(,string calc-language latex
                                  calc-prefer-frac t
                                  calc-angle-mode rad)))))
          (t (let ((l (thing-at-point 'line)))
               (end-of-line 1) (kill-line 0)
               (insert (calc-eval `(,l
                                    calc-language latex
                                    calc-prefer-frac t
                                    calc-angle-mode rad))))))))

(use-package preview
  :after latex
  :hook ((LaTeX-mode . preview-larger-previews))
  :config
  (defun preview-larger-previews ()
    (setq preview-scale-function
          (lambda () (* 1.25
                        (funcall (preview-scale-from-face)))))))

;; CDLatex settings
(use-package cdlatex
  :ensure t
  :hook (LaTeX-mode . turn-on-cdlatex)
  :bind (:map cdlatex-mode-map
              ("<tab>" . cdlatex-tab)))

;; Yasnippet settings
(use-package yasnippet
  :ensure t
  :hook ((LaTeX-mode . yas-minor-mode)
         (post-self-insert . my/yas-try-expanding-auto-snippets))
  :config
  (use-package warnings
    :config
    (cl-pushnew '(yasnippet backquote-change)
                warning-suppress-types
                :test 'equal))

  (setq yas-triggers-in-field t)

  ;; Function that tries to autoexpand YaSnippets
  ;; The double quoting is NOT a typo!
  (defun my/yas-try-expanding-auto-snippets ()
    (when (and (boundp 'yas-minor-mode) yas-minor-mode)
      (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
        (yas-expand)))))

;; CDLatex integration with YaSnippet: Allow cdlatex tab to work inside Yas
;; fields
(use-package cdlatex
  :hook ((cdlatex-tab . yas-expand)
         (cdlatex-tab . cdlatex-in-yas-field))
  :config
  (use-package yasnippet
    :bind (:map yas-keymap
                ("<tab>" . yas-next-field-or-cdlatex)
                ("TAB" . yas-next-field-or-cdlatex))
    :config
    (defun cdlatex-in-yas-field ()
      ;; Check if we're at the end of the Yas field
      (when-let* ((_ (overlayp yas--active-field-overlay))
                  (end (overlay-end yas--active-field-overlay)))
        (if (>= (point) end)
            ;; Call yas-next-field if cdlatex can't expand here
            (let ((s (thing-at-point 'sexp)))
              (unless (and s (assoc (substring-no-properties s)
                                    cdlatex-command-alist-comb))
                (yas-next-field-or-maybe-expand)
                t))
          ;; otherwise expand and jump to the correct location
          (let (cdlatex-tab-hook minp)
            (setq minp
                  (min (save-excursion (cdlatex-tab)
                                       (point))
                       (overlay-end yas--active-field-overlay)))
            (goto-char minp) t))))

    (defun yas-next-field-or-cdlatex nil
      (interactive)
      "Jump to the next Yas field correctly with cdlatex active."
      (if
          (or (bound-and-true-p cdlatex-mode)
              (bound-and-true-p org-cdlatex-mode))
          (cdlatex-tab)
        (yas-next-field-or-maybe-expand)))))

;; Array/tabular input with org-tables and cdlatex
(use-package org-table
  :after cdlatex
  :bind (:map orgtbl-mode-map
              ("<tab>" . lazytab-org-table-next-field-maybe)
              ("TAB" . lazytab-org-table-next-field-maybe))
  :init
  (add-hook 'cdlatex-tab-hook 'lazytab-cdlatex-or-orgtbl-next-field 90)
  ;; Tabular environments using cdlatex
  (add-to-list 'cdlatex-command-alist '("smat" "Insert smallmatrix env"
                                        "\\left( \\begin{smallmatrix} ? \\end{smallmatrix} \\right)"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("bmat" "Insert bmatrix env"
                                        "\\begin{bmatrix} ? \\end{bmatrix}"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("pmat" "Insert pmatrix env"
                                        "\\begin{pmatrix} ? \\end{pmatrix}"
                                        lazytab-position-cursor-and-edit
                                        nil nil t))
  (add-to-list 'cdlatex-command-alist '("tbl" "Insert table"
                                        "\\begin{table}\n\\centering ? \\caption{}\n\\end{table}\n"
                                        lazytab-position-cursor-and-edit
                                        nil t nil))
  :config
  ;; Tab handling in org tables
  (defun lazytab-position-cursor-and-edit ()
    ;; (if (search-backward "\?" (- (point) 100) t)
    ;;     (delete-char 1))
    (cdlatex-position-cursor)
    (lazytab-orgtbl-edit))

  (defun lazytab-orgtbl-edit ()
    (advice-add 'orgtbl-ctrl-c-ctrl-c :after #'lazytab-orgtbl-replace)
    (orgtbl-mode 1)
    (open-line 1)
    (insert "\n|"))

  (defun lazytab-orgtbl-replace (_)
    (interactive "P")
    (unless (org-at-table-p) (user-error "Not at a table"))
    (let* ((table (org-table-to-lisp))
           params
           (replacement-table
            (if (texmathp)
                (lazytab-orgtbl-to-amsmath table params)
              (orgtbl-to-latex table params))))
      (kill-region (org-table-begin) (org-table-end))
      (open-line 1)
      (push-mark)
      (insert replacement-table)
      (align-regexp (region-beginning) (region-end) "\\([:space:]*\\)& ")
      (orgtbl-mode -1)
      (advice-remove 'orgtbl-ctrl-c-ctrl-c #'lazytab-orgtbl-replace)))

  (defun lazytab-orgtbl-to-amsmath (table params)
    (orgtbl-to-generic
     table
     (org-combine-plists
      '(:splice t
        :lstart ""
        :lend " \\\\"
        :sep " & "
        :hline nil
        :llend "")
      params)))

  (defun lazytab-cdlatex-or-orgtbl-next-field ()
    (when (and (bound-and-true-p orgtbl-mode)
               (org-table-p)
               (looking-at "[[:space:]]*\\(?:|\\|$\\)")
               (let ((s (thing-at-point 'sexp)))
                 (not (and s (assoc s cdlatex-command-alist-comb)))))
      (call-interactively #'org-table-next-field)
      t))

  (defun lazytab-org-table-next-field-maybe ()
    (interactive)
    (if (bound-and-true-p cdlatex-mode)
        (cdlatex-tab)
      (org-table-next-field))))
