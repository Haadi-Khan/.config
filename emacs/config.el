(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-refresh-contents)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(setq use-package-always-ensure t)

(use-package evil
  :init      ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))
(use-package evil-collection ;; adds vim everywhere
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))
(use-package evil-tutor)

(use-package general
  :config
  (general-evil-setup t))

;; Using garbage magic hack.
 (use-package gcmh
   :config
   (gcmh-mode 1))
;; Setting garbage collection threshold
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive (setq comp-async-report-warnings-errors nil)
(setq gc-cons-threshold (* 2 1000 1000))

;; Silence compiler warnings as they can be pretty disruptive
(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-deferred-compilation nil))
;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; to skip the mtime checks on every *.elc file.
(setq load-prefer-newer noninteractive)

(use-package doom-themes)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
(load-theme 'doom-one t)

(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(electric-pair-mode 1)
(setq display-line-numbers-type 'relative)
(setq scroll-margin 8)

(require 'fill-column-indicator)
(setq-default fill-column-indicator '(foreground-color . "#E0DFDB"))
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

(centaur-tabs-mode 1)

(use-package doom-modeline)
(doom-modeline-mode 1)

(use-package all-the-icons)

(set-face-attribute 'default nil
  :font "Roboto Mono"
  :height 140
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "Roboto Mono"
  :height 160
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "Roboto Mono"
  :height 110
  :weight 'medium)
;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

;; Needed if using emacsclient. Otherwise, your fonts will be smaller than expected.
(add-to-list 'default-frame-alist '(font . "Roboto Mono-11"))
;; changes certain keywords to symbols, such as lamda!
(setq global-prettify-symbols-mode t)

;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package emojify
  :hook (after-init . global-emojify-mode))

(delete-selection-mode t)

(nvmap :prefix "SPC"
       "b b"   '(ibuffer :which-key "Ibuffer")
       "b c"   '(clone-indirect-buffer-other-window :which-key "Clone indirect buffer other window")
       "b k"   '(kill-current-buffer :which-key "Kill current buffer")
       "b n"   '(next-buffer :which-key "Next buffer")
       "b p"   '(previous-buffer :which-key "Previous buffer")
       "b B"   '(ibuffer-list-buffers :which-key "Ibuffer list buffers")
       "b K"   '(kill-buffer :which-key "Kill buffer"))

(use-package dashboard
  :init      ;; tweak dashboard config before loading it
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs: Richard Stallman's Second Favorite Fetish")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.emacs.d/emacs-dash.png")  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
			      (bookmarks . "book"))))

(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "e b"   '(eval-buffer :which-key "Eval elisp in buffer")
       "e d"   '(eval-defun :which-key "Eval defun")
       "e e"   '(eval-expression :which-key "Eval elisp expression")
       "e l"   '(eval-last-sexp :which-key "Eval last sexression")
       "e r"   '(eval-region :which-key "Eval region"))

(use-package all-the-icons-dired)
(use-package dired-open)
(use-package peep-dired)

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
               "d d" '(dired :which-key "Open dired")
               "d j" '(dired-jump :which-key "Dired jump to current")
               "d p" '(peep-dired :which-key "Peep-dired"))

(with-eval-after-load 'dired
  ;;(define-key dired-mode-map (kbd "M-p") 'peep-dired)
  (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
  (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
  (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
  (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file))

(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "sxiv")
                              ("jpg" . "sxiv")
                              ("png" . "sxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "."     '(find-file :which-key "Find file")
       "f f"   '(find-file :which-key "Find file")
       "f r"   '(counsel-recentf :which-key "Recent files")
       "f s"   '(save-buffer :which-key "Save file")
       "f u"   '(sudo-edit-find-file :which-key "Sudo find file")
       "f y"   '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "f C"   '(copy-file :which-key "Copy file")
       "f D"   '(delete-file :which-key "Delete file")
       "f R"   '(rename-file :which-key "Rename file")
       "f S"   '(write-file :which-key "Save file as...")
       "f U"   '(sudo-edit :which-key "Sudo edit file"))

(use-package recentf
  :config
  (recentf-mode))
(use-package sudo-edit) ;; Utilities for opening files with sudo

(defun dt/show-and-copy-buffer-path ()
  "Show and copy the full path to the current file in the minibuffer."
  (interactive)
  ;; list-buffers-directory is the variable set in dired buffers
  (let ((file-name (or (buffer-file-name) list-buffers-directory)))
    (if file-name
        (message (kill-new file-name))
      (error "Buffer not visiting a file"))))
(defun dt/show-buffer-path-name ()
  "Show the full path to the current file in the minibuffer."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if file-name
        (progn
          (message file-name)
          (kill-new file-name))
      (error "Buffer not visiting a file"))))

;; Spell Checking
(use-package flyspell-popup)
(require 'flyspell)
(add-hook 'text-mode-hook 'flyspell-mode)
(setq ispell-program-name "hunspell")
;;(add-hook 'text-mode-hook 'visual-line-mode)
;;(defvar mu-languages-ring nil "Languages ring for Ispell")
;;
;;(let ((languages '("en_US" "es_ES")))
  ;;(validate-setq mu-languages-ring (make-ring (length languages)))
  ;;(dolist (elem languages) (ring-insert mu-languages-ring elem)))
;;
;;(defun mu-cycle-ispell-languages ()
  ;;(interactive)
  ;;(let ((language (ring-ref mu-languages-ring -1)))
    ;;(ring-insert mu-languages-ring language)
    ;;(ispell-change-dictionary language)))

(nvmap :keymaps 'override :prefix "SPC"
       "SPC"   '(counsel-M-x :which-key "M-x")
       "c c"   '(compile :which-key "Compile")
       "c C"   '(recompile :which-key "Recompile")
       "h r r" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config")
       "t t"   '(toggle-truncate-lines :which-key "Toggle truncate lines"))
(nvmap :keymaps 'override :prefix "SPC"
       "m *"   '(org-ctrl-c-star :which-key "Org-ctrl-c-star")
       "m +"   '(org-ctrl-c-minus :which-key "Org-ctrl-c-minus")
       "m ."   '(counsel-org-goto :which-key "Counsel org goto")
       "m d"   '(org-deadline :which-key "Org set deadline")'
       "m e"   '(org-export-dispatch :which-key "Org export dispatch")
       "m f"   '(org-footnote-new :which-key "Org footnote new")
       "m h"   '(org-toggle-heading :which-key "Org toggle heading")
       "m i"   '(org-toggle-item :which-key "Org toggle item")
       "m n"   '(org-store-link :which-key "Org store link")
       "m o"   '(org-set-property :which-key "Org set property")
       "m s"   '(org-schedule :which-key "Org set schedule")'
       "m t"   '(org-todo :which-key "Org todo")
       "m x"   '(org-toggle-checkbox :which-key "Org toggle checkbox")
       "m B"   '(org-babel-tangle :which-key "Org babel tangle")
       "m I"   '(org-toggle-inline-images :which-key "Org toggle inline imager")
       "m T"   '(org-todo-list :which-key "Org todo list")
       "o a"   '(org-agenda :which-key "Org agenda")
       )

(use-package counsel
  :after ivy
  :config (counsel-mode))
(use-package ivy
  :defer 0.1
  :diminish
  :bind
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))
(use-package ivy-rich
  :after ivy
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer)
  (ivy-rich-mode 1)) ;; this gets us descriptions in M-x.
(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(setq ivy-initial-inputs-alist nil)

(use-package smex)
(smex-initialize)

(use-package ivy-posframe
  :init
  (setq ivy-posframe-display-functions-alist
    '((swiper                     . ivy-posframe-display-at-point)
      (complete-symbol            . ivy-posframe-display-at-point)
      (counsel-M-x                . ivy-display-function-fallback)
      (counsel-esh-history        . ivy-posframe-display-at-window-center)
      (counsel-describe-function  . ivy-display-function-fallback)
      (counsel-describe-variable  . ivy-display-function-fallback)
      (counsel-find-file          . ivy-display-function-fallback)
      (counsel-recentf            . ivy-display-function-fallback)
      (counsel-register           . ivy-posframe-display-at-frame-bottom-window-center)
      (dmenu                      . ivy-posframe-display-at-frame-top-center)
      (nil                        . ivy-posframe-display))
    ivy-posframe-height-alist
    '((swiper . 20)
      (dmenu . 20)
      (t . 10)))
  :config
  (ivy-posframe-mode 1)) ; 1 enables posframe-mode, 0 disables it.

(condition-case nil
    (require 'use-package)
  (file-error
   (require 'package)
   (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
   (package-initialize)
   (package-refresh-contents)
   (package-install 'use-package)
   (setq use-package-always-ensure t)
   (require 'use-package)))

(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))
(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config (setq lsp-completion-enable-additional-text-edit nil))
(use-package hydra)
(use-package company)
(use-package lsp-ui)
(use-package which-key :config (which-key-mode))
(use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)
(use-package helm-lsp)
(use-package helm
  :config (helm-mode))
(use-package lsp-treemacs)
(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)





(use-package markdown-mode)

(setq bare-git-dir (concat "--git-dir=" (expand-file-name "~/.dotfiles")))
(setq bare-work-tree (concat "--work-tree=" (expand-file-name "~")))
;; use maggit on git bare repos like dotfiles repos, don't forget to change `bare-git-dir' and `bare-work-tree' to your needs
(defun me/magit-status-bare ()
  "set --git-dir and --work-tree in `magit-git-global-arguments' to `bare-git-dir' and `bare-work-tree' and calls `magit-status'"
  (interactive)
  (require 'magit-git)
  (add-to-list 'magit-git-global-arguments bare-git-dir)
  (add-to-list 'magit-git-global-arguments bare-work-tree)
  (call-interactively 'magit-status))

;; if you use `me/magit-status-bare' you cant use `magit-status' on other other repos you have to unset `--git-dir' and `--work-tree'
;; use `me/magit-status' insted it unsets those before calling `magit-status'
(defun me/magit-status ()
  "removes --git-dir and --work-tree in `magit-git-global-arguments' and calls `magit-status'"
  (interactive)
  (require 'magit-git)
  (setq magit-git-global-arguments (remove bare-git-dir magit-git-global-arguments))
  (setq magit-git-global-arguments (remove bare-work-tree magit-git-global-arguments))
  (call-interactively 'magit-status))

(use-package magit)

;; Function for setting a fixed width for neotree.
;; Defaults to 25 but I make it a bit longer (35) in the 'use-package neotree'.
(defcustom neo-window-width 25
  "*Specifies the width of the NeoTree window."
  :type 'integer
  :group 'neotree)

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-window-width 30
        neo-theme (if (display-graphic-p) 'icons 'arrow)
        ;;neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

;; show hidden files
(setq-default neo-show-hidden-files t)

(nvmap :prefix "SPC"
       "t n"   '(neotree-toggle :which-key "Toggle neotree file viewer")
       "d n"   '(neotree-dir :which-key "Open directory in neotree"))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
(add-hook 'org-mode-hook 'org-indent-mode)
(setq org-directory "~/org/"
      org-agenda-files '("~/org/todos.org")
      org-default-notes-file (expand-file-name "notes.org" org-directory)
      org-ellipsis " ▼ "
      org-log-done 'time
      org-journal-dir "~/org/journal/"
      org-journal-date-format "%B %d, %Y (%A) "
      org-journal-file-format "%Y-%m-%d.org"
      org-hide-emphasis-markers t)
(setq org-src-preserve-indentation nil
      org-src-tab-acts-natively t
      org-edit-src-content-indentation 0)
(custom-set-faces
    '(org-level-1 ((t (:inherit outline-1 :height 1.15))))
    '(org-level-2 ((t (:inherit outline-2 :height 1.125))))
    '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
    '(org-level-4 ((t (:inherit outline-4 :height 1.075))))
    '(org-level-5 ((t (:inherit outline-5 :height 1.05))))
)

(use-package org-superstar ; "prettier" bullets
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
          ("[X]"  . 9745))))

;; An example of how this works.
;; [[arch-wiki:Name_of_Page][Description]]
(setq org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
        '(("google" . "http://www.google.com/search?q=")
          ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
          ("ddg" . "https://duckduckgo.com/?q=")
          ("wiki" . "https://en.wikipedia.org/wiki/")))

(setq org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
    '((sequence
             "TODO(t)"
             "APUSH(a)"
             "STAT(s)"
             "PHYSICS(P)"
             "CALC(C)"
             "LANG(l)"
             "SPAN(f)"
             "MULTI(m)"
             "CS(S)"
             "ROBO(r)"
             "SCIOLY(g)"
             "|"
             "DONE(d)"
             "CANCELLED(c)"
             "|"
             "PROG(p)"))
    )

(use-package org-tempo
  :ensure nil) ;; tell use-package not to try to install org-tempo since it's already there.

(setq org-src-fontify-natively t
    org-src-tab-acts-natively t
    org-confirm-babel-evaluate nil
    org-edit-src-content-indentation 0)

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(setq org-blank-before-new-entry (quote ((heading . nil)
                                         (plain-list-item . nil))))

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)   ; or use a nicer switcher, see below
  :config
  (persp-mode))

(use-package projectile
  :config
  (projectile-global-mode 1))

(nvmap :prefix "SPC"
       "r c"   '(copy-to-register :which-key "Copy to register")
       "r f"   '(frameset-to-register :which-key "Frameset to register")
       "r i"   '(insert-register :which-key "Insert register")
       "r j"   '(jump-to-register :which-key "Jump to register")
       "r l"   '(list-registers :which-key "List registers")
       "r n"   '(number-to-register :which-key "Number to register")
       "r r"   '(counsel-register :which-key "Choose a register")
       "r v"   '(view-register :which-key "View a register")
       "r w"   '(window-configuration-to-register :which-key "Window configuration to register")
       "r +"   '(increment-register :which-key "Increment register")
       "r SPC" '(point-to-register :which-key "Point to register"))

(setq scroll-conservatively 101) ;; value greater than 100 gets rid of half page jumping
(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; how many lines at a time
(setq mouse-wheel-progressive-speed t) ;; accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(nvmap :prefix "SPC"
       "e h"   '(counsel-esh-history :which-key "Eshell history")
       "e s"   '(eshell :which-key "Eshell"))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "htop" "ssh" "top" "zsh"))

(use-package vterm)
(setq shell-file-name "/bin/zsh"
      vterm-max-scrollback 5000)

(winner-mode 1)
(nvmap :prefix "SPC"
       ;; Window splits
       "w c"   '(evil-window-delete :which-key "Close window")
       "w n"   '(evil-window-new :which-key "New window")
       "w s"   '(evil-window-split :which-key "Horizontal split window")
       "w v"   '(evil-window-vsplit :which-key "Vertical split window")
       ;; Window motions
       "w h"   '(evil-window-left :which-key "Window left")
       "w j"   '(evil-window-down :which-key "Window down")
       "w k"   '(evil-window-up :which-key "Window up")
       "w l"   '(evil-window-right :which-key "Window right")
       "w w"   '(evil-window-next :which-key "Goto next window")
       ;; winner mode
       "w <left>"  '(winner-undo :which-key "Winner undo")
       "w <right>" '(winner-redo :which-key "Winner redo"))

(use-package which-key
  :init
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t
        which-key-separator " → " ))
(which-key-mode)

(use-package writeroom-mode)

(setq
    make-backup-files nil
    auto-save-default nil
    create-lockfiles nil)

(use-package google-translate)
(require 'google-translate)
(require 'google-translate-default-ui)
