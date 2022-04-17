;;; private/roam/config.el -*- lexical-binding: t; -*-

;; I encountered the following message when attempting
;; to export data:
;;
;; "org-export-data: Unable to resolve link: FILE-ID"
(after! org-roam
  (defun +org/force-org-rebuild-cache ()
    "Rebuild the `org-mode' and `org-roam' cache."
    (interactive)
    (org-id-update-id-locations)
    ;; Note: you may need `org-roam-db-clear-all'
    ;; followed by `org-roam-db-sync'
    (org-roam-db-sync)
    (org-roam-update-org-id-locations)))

(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;    :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))
