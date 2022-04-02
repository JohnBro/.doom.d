;;; private/qualcomm/config.el -*- lexical-binding: t; -*-

(after! org
  (defvar +org-capture-case-file "case.org"
    "Default target for storing timestamped Qualcomm case entries.

Is relative to `org-directory', unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

  (setq +org-capture-case-file
        (expand-file-name +org-capture-case-file org-directory))

  (add-to-list 'org-capture-templates
               '("c" "Qualcomm Case Notes" entry
                 (file+olp+datetree +org-capture-case-file)
                 "* TODO %T [%?,SR#] %^g\n%i\n" :prepare t :unnarrowed t)))
