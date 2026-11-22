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
    (setq-local gptel-model 'deepseek-v4-flash
                gptel-backend (gptel-get-backend "DeepSeek")
                buffer-save-without-query t)
    (add-to-list 'gptel-post-response-functions
                 (lambda (&rest _) (when (buffer-modified-p) (save-buffer)))))
  )

(defun llm-integration-init ()
  "Configure gptel and MCP."
  (setq gptel-use-tools t
        gptel-default-mode 'org-mode
        mcp-hub-servers '(("web" . (:url "http://localhost:5353/mcp"))))
  (gptel-make-deepseek "DeepSeek"
    :stream t
    :key (lambda () (password-store-get-cached "dev/deepseek.com/key")))
  (add-hook 'gptel-mode-hook 'company-mode)
  (setf (alist-get 'default gptel-directives)
        "You write about the conceptual ideas behind questions rather than explaining the details unless asked. Your answers are short and to the point without adding extra information while keeping them full. Respond in valid Org Mode syntax avoiding tables.")

  (add-hook 'after-init-hook
            (lambda ()
              (gptel-mcp-connect '("web")))))

(unless noninteractive
  (llm-integration-init))

(provide 'llm-integration)
;;; llm-integration.el ends here
