;;; llm-integration.el --- LLM and MCP integration -*- lexical-binding: t; -*-

;;; Commentary:
;; gptel backends, tools, directives and MCP server wiring.

;;; Code:

(require 'gptel)
(require 'mcp)
(require 'gptel-integrations)
(require 'pass-integration)
(require 'org)

(defvar gptel-sessions-dir (expand-file-name "gptel/" org-directory) "The directory where gptel sessions are saved.")

(defun deepseek ()
  "Spawn a gptel buffer with deepseek that auto-saves to a file in gptel-sessions-dir."
  (interactive)
  (let ((default-directory gptel-sessions-dir))
    (call-interactively #'find-file)
    (gptel-mode 1)
    (auto-save-mode -1)
    (undo-tree-mode -1)
    (flycheck-mode -1)
    (add-to-list 'gptel-post-response-functions
                 (lambda (&rest _) (when (buffer-modified-p) (save-buffer)))))
  )

(defun llm-integration-init ()
  "Configure gptel and MCP."
  (gptel-make-deepseek "DeepSeek"
    :stream t
    :key (lambda () (password-store-get-cached "dev/deepseek.com/key")))
  (setq gptel-backend (gptel-get-backend "DeepSeek")
        gptel-model 'deepseek-v4-flash
        gptel-use-tools t
        gptel-default-mode 'org-mode
        gptel-org-convert-response t
        mcp-hub-servers '(("web" . (:url "http://localhost:5353/mcp")))
        jsonrpc-default-request-timeout 120)
  (add-hook 'gptel-mode-hook 'company-mode)
  (setf (alist-get 'default gptel-directives)
        "You write about the conceptual ideas behind questions rather than explaining the details unless asked. Your answers are short and to the point without adding extra information while keeping them full."
        (alist-get 'org-mode gptel-prompt-prefix-alist) "* "
        (alist-get 'org-mode gptel-response-prefix-alist) "** \n")

  (add-hook 'after-init-hook
            (lambda ()
              (gptel-mcp-connect
               '(("web" "fetch" "search")))
              ))
  )

(unless noninteractive
  (llm-integration-init))

(provide 'llm-integration)
;;; llm-integration.el ends here
