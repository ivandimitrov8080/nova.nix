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
