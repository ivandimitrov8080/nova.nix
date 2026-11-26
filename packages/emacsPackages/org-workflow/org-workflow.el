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

(defvar org-agenda-inbox (file-name-concat org-directory "inbox.org"))
(defvar org-agenda-projects (file-name-concat org-directory "projects.org"))

(defun org-workflow-save-org-buffers (&rest _)
  "Quietly save all Org buffers.  Safe to call from hooks and advice."
  (let ((inhibit-message t))
    (condition-case err
        (org-save-all-org-buffers)
      (error (message "org-workflow: save failed: %s" (error-message-string err))))))

(defun org-workflow-auto-save-setup ()
  "Configure saving orgmode buffers when TODOs change."
  (add-hook 'org-after-todo-state-change-hook #'org-workflow-save-org-buffers)
  (add-hook 'org-after-tags-change-hook      #'org-workflow-save-org-buffers)
  (add-hook 'org-after-note-stored-hook      #'org-workflow-save-org-buffers)
  (add-hook 'org-after-refile-insert-hook    #'org-workflow-save-org-buffers)
  ;; refile hook fires before the source subtree is deleted, so save after the whole command
  (advice-add 'org-refile :after #'org-workflow-save-org-buffers)
  ;; properties / planning / priority / archiving have no hook
  (dolist (cmd '(org-set-property org-delete-property org-schedule org-deadline
                                  org-priority org-set-effort org-set-tags-command
                                  org-archive-subtree org-archive-to-archive-sibling))
    (advice-add cmd :after #'org-workflow-save-org-buffers)))

(defun org-caldav-insert-parent-rel (&rest _)
  "Add RELATED-TO;RELTYPE=PARENT from the parent heading's :ID:."
  (let* ((uid (org-caldav-get-uid))
         (pid (and uid
                   (save-window-excursion
                     (org-id-goto uid)
                     (let ((p (org-element-property :parent (org-element-at-point))))
                       (and p (org-element-property :ID p)))))))
    (when pid
      (save-excursion
        (goto-char (point-max))
        (when (search-backward "END:VTODO" nil t)
          (beginning-of-line)
          (let ((eol (if (save-excursion (goto-char (point-min))
                                         (search-forward "\r\n" (line-end-position) t))
                         "\r\n" "\n")))
            (insert "RELATED-TO;RELTYPE=PARENT:" pid eol)))))))

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
                          '("inbox.org" "projects.org"))
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d)" "CANCELLED(c@)"))
        org-stuck-projects '("+LEVEL=2/-DONE" ("NEXT") nil "")
        org-log-done 'time
        org-log-refile 'time
        org-log-into-drawer t
        org-refile-targets '((org-agenda-files :maxlevel . 6))
        org-refile-use-outline-path 'file
        org-refile-allow-creating-parent-nodes 'confirm
        org-agenda-span 'month
        org-archive-location (file-name-concat org-directory "archive.org::* Archived"))
  (setq org-capture-templates
        '(("t" "Task → inbox" entry (file "inbox.org")
           "* TODO %?\n%U\n" :empty-lines 1)
          ("n" "Note → inbox" entry (file "inbox.org")
           "* %?\n%U\n" :empty-lines 1)))
  (setq org-agenda-custom-commands
        '(("n" "Next actions" todo "NEXT")
          ("i" "Inbox — process me" alltodo ""
           ((org-agenda-files (list org-agenda-inbox))))
          ("R" "Review"
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
        org-caldav-inbox org-agenda-inbox
        org-caldav-files (list org-agenda-projects)
        org-caldav-delete-org-entries 'never
        org-caldav-todo-percent-states '((0 "TODO") (10 "NEXT") (50 "WAITING") (100 "DONE"))
        org-icalendar-timezone "Asia/Bangkok"
        org-icalendar-include-todo '("TODO" "NEXT" "WAITING" "DONE"))
  (advice-add 'org-caldav-put-event :before #'org-caldav-insert-parent-rel)

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

  (org-workflow-auto-save-setup)

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
