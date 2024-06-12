;;; argumentative.el -*- lexical-binding: t; -*-

(require 'evil)

(defvar argumentative-pairs
  '((?\( . ?\))
    (?\{ . ?\})
    (?\[ . ?\])
    (?\) . ?\()
    (?\} . ?\{)
    (?\] . ?\[)))

(defun argumentative-get-pair (char)
  "Get the matching pair for CHAR."
  (cdr (assoc char argumentative-pairs)))

(defun argumentative-is-open (char direction)
  "Check if CHAR is an opening or closing character based on DIRECTION."
  (if direction
      (memq char '(?\( ?\{ ?\[))
    (memq char '(?\) ?\} ?\]))))

(defun argumentative-getchar (&optional offset)
  "Get the character at point with an optional OFFSET."
  (char-after (+ (point) (or offset 0))))

(defun argumentative-skip (direction &optional start end)
  "Skip characters based on DIRECTION and optional START and END positions."
  (let ((char (argumentative-getchar))
        (stack '()))
    (while (and (not (eobp))
                (or (not (null stack))
                    (not (argumentative-is-open char direction))
                    (and (not direction) (eq char ?,))))
      (if (argumentative-is-open char direction)
          (push char stack)
        (when (eq (argumentative-get-pair char) (car stack))
          (pop stack)))
      (forward-char (if direction 1 -1))
      (setq char (argumentative-getchar)))))

(defun argumentative-arg-motion (direction)
  "Move to the next argument boundary considering nesting and DIRECTION."
  (let ((stack '())
        (char (argumentative-getchar)))
    (if (argumentative-is-implicit-function-call)
        (let ((start (save-excursion
                       (search-backward-regexp "\\_<\\(\\k\\|\\(\\()\\|\\[\\|{\\)")
                       (point)))
              (end (save-excursion
                     (search-forward-regexp "\\_>\\(\\k\\|\\)\\s-+\\(\\(\\()\\|\\[\\|{\\)")
                     (point))))
          (goto-char start)
          (argumentative-skip direction start end))
      (argumentative-skip direction))))

(defun argumentative-is-implicit-function-call ()
  "Check if the current line represents an implicit function call."
  (and (memq major-mode '(ruby-mode coffee-mode))
       (save-excursion
         (beginning-of-line)
         (looking-at "\\_>\\(\\k\\|\\)\\s-+\\(\\(\\()\\|\\[\\|{\\)"))))

(defun argumentative-move (direction)
  "Move to the previous or next argument based on DIRECTION."
  (let ((start (point))
        (outer (argumentative-outer-text-object)))
    (goto-char start)
    (let ((inner (argumentative-inner-text-object)))
      (if direction
          (progn
            (goto-char (nth 1 outer))
            (argumentative-arg-motion direction))
        (goto-char (nth 0 outer))
        (unless (eq (argumentative-getchar) ?,)
          (argumentative-arg-motion direction)))
      (let ((new-inner (argumentative-inner-text-object)))
        (argumentative-exchange inner new-inner))
      (argumentative-arg-motion t))))

(defun argumentative-outer-text-object ()
  "Define the outer text object for argument."
  (let ((start (point))
        (char (argumentative-getchar)))
    (if (argumentative-is-open char t)
        (progn
          (argumentative-arg-motion t)
          (let ((end (point)))
            (argumentative-arg-motion nil)
            (list (point) end)))
      (progn
        (argumentative-arg-motion nil)
        (let ((start (point)))
          (argumentative-arg-motion t)
          (list start (point)))))))

(defun argumentative-inner-text-object ()
  "Define the inner text object for argument."
  (let ((outer (argumentative-outer-text-object)))
    (goto-char (nth 0 outer))
    (search-forward-regexp "\\S-")
    (let ((start (point)))
      (goto-char (nth 1 outer))
      (search-backward-regexp "\\S-")
      (list start (point)))))

(defun argumentative-exchange (a b)
  "Exchange the text objects defined by A and B."
  (let ((text-a (buffer-substring-no-properties (nth 0 a) (nth 1 a)))
        (text-b (buffer-substring-no-properties (nth 0 b) (nth 1 b))))
    (delete-region (nth 0 a) (nth 1 a))
    (goto-char (nth 0 a))
    (insert text-b)
    (delete-region (nth 0 b) (nth 1 b))
    (goto-char (nth 0 b))
    (insert text-a)))

(defun argumentative-count (fn)
  "Call the function FN for the count of the operator."
  (dotimes (_ (or (and (boundp 'evil-this-operator-count)
                       evil-this-operator-count)
                  1))
    (funcall fn)))

(evil-define-command argumentative-prev ()
  (interactive)
  (argumentative-count (lambda () (argumentative-arg-motion nil))))

(evil-define-command argumentative-next ()
  (interactive)
  (argumentative-count (lambda () (argumentative-arg-motion t))))

(evil-define-command argumentative-move-left ()
  (interactive)
  (argumentative-count (lambda () (argumentative-move nil))))

(evil-define-command argumentative-move-right ()
  (interactive)
  (argumentative-count (lambda () (argumentative-move t))))

(evil-define-text-object argumentative-inner-text-object (count &optional beg end type)
  (argumentative-inner-text-object))

(evil-define-text-object argumentative-outer-text-object (count &optional beg end type)
  (argumentative-outer-text-object))

(define-key evil-normal-state-map (kbd "[,") 'argumentative-prev)
(define-key evil-normal-state-map (kbd "],") 'argumentative-next)
(define-key evil-visual-state-map (kbd "[,") 'argumentative-prev)
(define-key evil-visual-state-map (kbd "],") 'argumentative-next)
(define-key evil-normal-state-map (kbd "<,") 'argumentative-move-left)
(define-key evil-normal-state-map (kbd ">,") 'argumentative-move-right)

(define-key evil-visual-state-map (kbd "i,") 'argumentative-inner-text-object)
(define-key evil-visual-state-map (kbd "a,") 'argumentative-outer-text-object)
(define-key evil-operator-state-map (kbd "i,") 'argumentative-inner-text-object)
(define-key evil-operator-state-map (kbd "a,") 'argumentative-outer-text-object)
