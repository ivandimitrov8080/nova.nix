;;; media-playback.el --- Media playback -*- lexical-binding: t; -*-

;;; Commentary:
;; EMMS and Transmission integration, including YouTube URL handlers.

;;; Code:

(require 'emms-setup)
(require 'transmission)

(defconst emms-last-track (concat user-emacs-directory "emms-last-track"))

(defun emms-save-last ()
  "Saves last played file to disk."
  (with-temp-file emms-last-track (insert (prin1-to-string (emms-playlist-current-selected-track)))))

(defun emms-read-last ()
  "Reads last played file from disk."
  (if (file-exists-p emms-last-track)
      (with-temp-buffer
        (insert-file-contents emms-last-track)
        (read (current-buffer)))
    (message "Last track not saved yet.")
    nil))

(defun emms-select-by-name (track)
  "Selects and marks emms track by TRACK name."
  (if track
      (with-current-emms-playlist
        (goto-char (point-min))
        (when (search-forward (emms-track-name track) nil t)
          (emms-playlist-select (match-beginning 0))))
    (message "No track selected.")))

(defun browse-url-emms (url &rest _args)
  "Automatically open URL in REST mpv."
  (emms-play-url url))

(defun emms-mus ()
  "Loads emms with music directory."
  (interactive)
  (emms-playlist-current-clear)
  (emms-add-directory-tree "~/mus/")
  (emms-shuffle)
  (emms-start))

(defun emms-shows ()
  "Loads emms with shows directory."
  (interactive)
  (emms-stop)
  (emms-playlist-current-clear)
  (emms-add-directory-tree "~/shows/")
  (emms-select-by-name (emms-read-last))
  (emms))

(defun media-playback-init ()
  "Configure media playback."
  (emms-all)
  (setq emms-player-list '(emms-player-mpv)
        emms-info-functions '(emms-info-exiftool emms-info-native)
        emms-browser-covers #'emms-browser-cache-thumbnail-async
        emms-browser-thumbnail-small-size 64
        emms-browser-thumbnail-medium-size 128
        emms-track-description-function #'emms-info-track-description)
  (add-hook 'emms-player-started-hook #'emms-save-last)

  (setq browse-url-handlers
        `(("youtube\\.com/watch\\?v=.*" . browse-url-emms)
          ("youtube\\.com/shorts/.*" . browse-url-emms)
          ("youtu\\.be/.*" . browse-url-emms)))

  (setq transmission-refresh-interval 1
        transmission-refresh-modes '(transmission-mode
                                     transmission-files-mode
                                     transmission-info-mode
                                     transmission-peers-mode)))

(unless noninteractive
  (media-playback-init))

(provide 'media-playback)
;;; media-playback.el ends here
