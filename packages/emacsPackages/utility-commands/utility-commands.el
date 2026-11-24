;;; utility-commands.el --- Miscellaneous commands -*- lexical-binding: t; -*-

;;; Commentary:
;; Weather, translation, calendar import and host rebuild helpers.

;;; Code:

(require 'cl-lib)
(require 'org)
(require 'request)
(require 'xterm-color)
(require 'khalel)
(require 'ddgr)
(require 'button)

;; UTILITY FNS
(defvar web-search-history nil
  "History of queries entered with `web-search'.")

(defvar-keymap web-search-results-mode-map
  :parent special-mode-map
  "RET"       #'push-button
  "n"         #'forward-button
  "p"         #'backward-button
  "q"         #'quit-window)

(define-derived-mode web-search-results-mode special-mode "WebSearch"
  "Major mode for `web-search' results.")

(defun web-search--insert-result (title url content)
  "Inserts TITLE URL CONTENT as buttons."
  (insert-text-button (or title "(untitled)")
                      'face 'bold
                      'follow-link t
                      'help-echo (concat "Open " url)
                      'action (lambda (_) (browse-url url)))
  (insert "\n")
  (when (and content (not (string-empty-p content)))
    (insert content "\n"))
  (insert "\n"))

(defun web-search--results (data)
  "Return DATA's result list, whether wrapped in a \"results\" key or not."
  (let ((res (if (and (listp data) (assoc 'results data))
                 (alist-get 'results data)
               data)))
    (append res nil)))                ; vector -> list

(defun web-search--render (data)
  "Renders the search DATA in a readable way."
  (with-current-buffer (get-buffer-create "*web-search*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (let ((results (web-search--results data)))
        (if (null results)
            (insert "No results.\n")
          (dolist (r results)
            (web-search--insert-result (alist-get 'title r)
                                       (alist-get 'url r)
                                       (alist-get 'content r))))))
    (web-search-results-mode)
    (goto-char (point-min))
    (pop-to-buffer (current-buffer))))

;; UTILITY FNS

(defun wttr ()
  "Get the current weather."
  (interactive)
  (request "https://wttr.in/Da_Nang"
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (with-current-buffer (get-buffer-create "*wttr*")
                  (view-mode -1)
                  (erase-buffer)
                  (insert data)
                  (xterm-color-colorize-buffer)
                  (view-mode 1)
                  (pop-to-buffer (current-buffer)))))))

(defun translate ()
  "Translate a region."
  (interactive)
  (let* ((text (buffer-substring-no-properties (region-beginning) (region-end)))
         (url "http://localhost:5000/translate"))
    (request url
      :method "POST"
      :data `(("source" . "auto") ("target" . "en") ("q" . ,text))
      :parser 'json-read
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (with-current-buffer (get-buffer-create "*translate*")
                    (view-mode -1)
                    (erase-buffer)
                    (insert (assoc-default 'translatedText data))
                    (view-mode 1)
                    (pop-to-buffer (current-buffer))))))))

(defun web-search (query)
  "Search the web for QUERY."
  (interactive
   (list (read-string "Search query: " nil 'web-search-history)))
  (let* ((url "http://localhost:8080/search"))
    (request url
      :method "POST"
      :data (format "format=json&q=%s" query)
      :parser 'json-read
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (web-search--render data))))))

(defun rebuild-nova ()
  "Rebuild nova."
  (interactive)
  (compile "cd ~/src/hosts.nix; nixos-rebuild switch --flake --sudo"))

(defun rebuild-vps ()
  "Rebuild vpsfree-ivand."
  (interactive)
  (compile "askpass | ssh vpsfree-ivand 'cd ~/src/vps.nix; git pull; sudo -S nixos-rebuild switch --flake'"))

(defun utility-commands-init ()
  "Configure miscellaneous helpers."
  (setq khalel-import-org-file (concat org-directory "/calendar.org"))
  (add-to-list 'org-agenda-files (concat org-directory "/calendar.org")))

(unless noninteractive
  (utility-commands-init))

(provide 'utility-commands)
;;; utility-commands.el ends here
