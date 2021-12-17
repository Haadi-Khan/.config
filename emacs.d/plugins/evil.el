;; Evil Mode (Vi emulation)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)
(unless (package-installed-p 'evil)
  (package-install 'evil))
(require 'evil)
(evil-mode 1)
(custom-set-variables
 '(package-selected-packages '(evil)))
(custom-set-faces
 )
