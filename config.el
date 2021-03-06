;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Johnbro"
      user-mail-address "johnbro@foxmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(when IS-WINDOWS
  (setq doom-font (font-spec :family "Source Code Pro" :size 14 :weight 'regular)
        doom-variable-pitch-font (font-spec :family "Source Code Pro") ; inherits `doom-font''s :size
        doom-unicode-font (font-spec :family "Microsoft YaHei" :size 14)
        doom-big-font (font-spec :family "Source Code Pro" :size 20)))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(if IS-GUI (setq doom-theme 'doom-one)
  (setq doom-theme 'doom-dark+))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(defvar-local all-my-notes-directory
  "~/Notes"
  "Directory that save all my org/markdown/.. notes root directoy")
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (expand-file-name "org" all-my-notes-directory))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(progn
  (when IS-WINDOWS
    (progn
      (setq w32-apps-modifier 'super)                   ;; Define Super Key for Windnows
      (set-selection-coding-system 'utf-16le-dos))      ;; Fix Chinese character brocken issue
    )
  (when IS-MAC
    (progn
      (setq mac-option-modifier 'meta
            mac-command-modifier 'super))))

(global-set-key (kbd "s-a") 'mark-whole-buffer)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-x") 'kill-region)

;; init ui
(toggle-frame-maximized)

(after! deft
  (setq deft-directory all-my-notes-directory)
  (setq deft-recursive t)
  (setq deft-default-extension "org")
  (add-to-list 'deft-extensions "md")
  (add-to-list 'deft-extensions "org"))

(after! consult
  (if IS-WINDOWS
      (progn
        (add-to-list 'process-coding-system-alist '("es" gbk . gbk))
        (add-to-list 'process-coding-system-alist '("explorer" gbk . gbk))
        (setq consult-locate-args (encode-coding-string "es.exe -i -p -r" 'gbk))))
  (global-set-key (kbd "C-s") 'consult-line))

(after! which-key
  (setq which-key-idle-delay 0.05))

(after! company
  (setq company-minimum-prefix-length 2)
  (setq company-idle-delay 0.001))

(after! embark
  (defun consult-directory-externally (file)
    "Open FILE path externally using the default application of the system."
    (interactive "fOpen externally: ")
    (if (and (eq system-type 'windows-nt)
             (fboundp 'w32-shell-execute))
        (shell-command-to-string (encode-coding-string (replace-regexp-in-string "/" "\\\\"
                                                                                 (format "explorer.exe %s" (file-name-directory (expand-file-name file)))) 'gbk))
      (call-process (pcase system-type
                      ('darwin "open")
                      ('cygwin "cygstart")
                      (_ "xdg-open"))
                    nil 0 nil
                    (file-name-directory (expand-file-name file)))))
  (define-key embark-file-map (kbd "X") #'consult-directory-externally)
  (if (not IS-GUI)
      ;; Terminal define <C-;> as <escape>, so use <M-;> instead
      (map! (:map minibuffer-local-map
             "M-;" #'embark-act)
            (:map dired-mode-map
             "M-;" #'embark-act))))

(after! org
  (defvar +org-capture-habits-file "habits.org"
    "Default target for storing habits recording entries.

Is relative to `org-directory', unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

  (setq org-export-with-sub-superscripts '{})   ;; fix export "_" issue
  (setq +org-capture-habits-file
        (expand-file-name +org-capture-habits-file org-directory)))

(after! doom-modeline
  (setq doom-modeline-major-mode-icon t))

(use-package! mini-frame
  :after vertico
  :config
  (custom-set-variables
   '(mini-frame-show-parameters
     '((top . 10)
       (width . 0.7)
       (left . 0.5)))))

(use-package! youdao-dictionary
  :defer t
  :init
  (setq url-automatic-caching t)
  (global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point)             ;; Enable Cache
  (setq youdao-dictionary-search-history-file "~/.emacs.d/.local/.youdao")      ;; Set file path for saving search history
  (setq youdao-dictionary-use-chinese-word-segmentation t)                      ;; Enable Chinese word segmentation support (??????????????????)
  )

;; emacs-version >= 28.1 configurations
(when EMACS28+
  (progn
    (setq use-short-answers t)
    (setq kill-buffer-delete-auto-save-files t)
    (setq next-error-message-highlight t)
    (setq mode-line-compact t)
    (setq describe-bindings-outline t)))
