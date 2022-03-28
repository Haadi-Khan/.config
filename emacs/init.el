(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elfeed-feeds
   '
     ("https://www.reddit.com/r/linux.rss" reddit linux)
     ("https://www.reddit.com/r/commandline.rss" reddit commandline)
     ("https://www.reddit.com/r/distrotube.rss" reddit distrotube)
     ("https://www.reddit.com/r/emacs.rss" reddit emacs)
     ("https://www.gamingonlinux.com/article_rss.php" gaming linux)
     ("https://hackaday.com/blog/feed/" hackaday linux)
     ("https://opensource.com/feed" opensource linux)
     ("https://linux.softpedia.com/backend.xml" softpedia linux)
     ("https://itsfoss.com/feed/" itsfoss linux)
     ("https://www.zdnet.com/topic/linux/rss.xml" zdnet linux)
     ("https://www.phoronix.com/rss.php" phoronix linux)
     ("http://feeds.feedburner.com/d0od" omgubuntu linux)
     ("https://www.computerworld.com/index.rss" computerworld linux)
     ("https://www.networkworld.com/category/linux/index.rss" networkworld linux)
     ("https://www.techrepublic.com/rssfeeds/topic/open-source/" techrepublic linux)
     ("https://betanews.com/feed" betanews linux)
     ("http://lxer.com/module/newswire/headlines.rss" lxer linux)
     ("https://distrowatch.com/news/dwd.xml" distrowatch linux)))
 '(package-selected-packages
   '(elfeed treemacs-evil treemacs emojify highlight-indent-guides flyspell-popup centaur-tabs lsp-java markdown-mode magit LaTeX-mode writeroom-mode perspective neotree evil-tutor elfeed-goodies sudo-edit ox-man dired smex org-tempo all-the-icons-dired which-key vterm use-package toc-org projectile peep-dired org-bullets magit-todos magit-lfs ivy-rich ivy-posframe haskell-mode general evil-collection eshell-syntax-highlighting doom-themes doom-modeline dired-open dashboard counsel))
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
