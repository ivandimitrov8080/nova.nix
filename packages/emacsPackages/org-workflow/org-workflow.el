;;; org-workflow.el --- Org mode workflow -*- lexical-binding: t; -*-

;;; Commentary:
;; Org, capture, Babel, and the visual Org stack.

;;; Code:

(require 'org)
(require 'org-capture)
(require 'org-tempo)
(require 'org-habit)
(require 'olivetti)
(require 'valign)
(require 'org-modern)
(require 'org-appear)
(require 'mixed-pitch)
(require 'markdown-mode)
(require 'org-caldav)

(defun org-workflow-init ()
  "Configure Org mode and friends."
  (setq org-startup-indented t
        org-hide-leading-stars t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-src-content-indentation 2
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-pretty-entities-include-sub-superscripts nil
        org-ellipsis "  ...")

  (setq org-agenda-files (mapcar
                          (apply-partially #'file-name-concat org-directory)
                          '("inbox.org" "projects.org" "calendar.org"))
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d)" "CANCELLED(c@)"))
        org-todo-keyword-faces '(("NEXT"    . "green")
                                 ("WAITING" . "orange")
                                 ("SOMEDAY" . "grey50"))
        org-tag-alist '((:startgroup)
                        ("work" . ?w) ("home" . ?h)
                        (:endgroup)
                        ("project"    . ?p)
                        ("subproject" . ?s))
        org-tags-exclude-from-inheritance '("project" "subproject")
        org-stuck-projects '("+project" ("NEXT") nil "")
        org-log-done 'time
        org-log-refile 'time
        org-log-into-drawer t
        org-refile-targets '((org-agenda-files :maxlevel . 6))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-agenda-span 'week
        org-archive-location (file-name-concat org-directory "archive.org::* Archived"))
  (setq org-capture-templates
        '(("t" "Task → inbox" entry (file "inbox.org")
           "* TODO %?\n%U\n" :empty-lines 1)
          ("n" "Note → inbox" entry (file "inbox.org")
           "* %?\n%U\n" :empty-lines 1)))
  (setq org-agenda-custom-commands
        '(("n" "Next actions" todo "NEXT")
          ("w" "Waiting for" todo "WAITING")
          ("i" "Inbox — process me" alltodo ""
           ((org-agenda-files '("~/org/inbox.org"))))
          ("p" "Projects" tags-todo "project"
           ((org-agenda-overriding-header "Open projects")))
          ("R" "Weekly review"
           ((stuck "")
            (todo "NEXT")
            (todo "WAITING")
            (tags-todo "project")
            (agenda "" ((org-agenda-span 'week)))))))
  (add-to-list 'safe-local-eval-forms
               '(org-match-sparse-tree nil "TODO=\"NEXT\""))
  (global-set-key (kbd "C-c c") #'org-capture)
  (global-set-key (kbd "C-c a") #'org-agenda)

  (setq org-caldav-url "https://dav.idimitrov.dev/ivan@idimitrov.dev"
        org-caldav-calendar-id "10be6c74-1a5f-40ae-9036-74439790e4d2"
        org-caldav-inbox "~/org/calinbox.org"
        org-caldav-files nil
        org-icalendar-timezone "Asia/Bangkok")

  (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'mixed-pitch-mode)
  (set-face-attribute 'org-level-1 nil :height 1.3 :weight 'bold)
  (set-face-attribute 'org-level-2 nil :height 1.15 :weight 'semibold)

  (add-hook 'org-mode-hook #'valign-mode)
  (add-hook 'markdown-mode-hook #'valign-mode)

  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
  (setq org-modern-star 'replace
        org-modern-hide-stars 'leading
        org-modern-todo t
        org-modern-table t
        org-modern-tag t
        org-modern-priority t
        org-modern-keyword t
        org-modern-block-name nil
        org-modern-list '((43 . "•") (45 . "–") (42 . "•"))
        org-modern-checkbox '((?X . "☑") (?- . "◐") (?\s . "☐")))

  (add-hook 'org-mode-hook #'org-appear-mode)

  (add-hook 'org-mode-hook #'olivetti-mode)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (haskell . t)
     (nix . t)))

  (setq org-confirm-babel-evaluate t
        org-src-preserve-indentation t
        haskell-process-type 'ghci))

(unless noninteractive
  (org-workflow-init))

(provide 'org-workflow)
;;; org-workflow.el ends here
