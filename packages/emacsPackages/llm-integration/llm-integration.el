;;; llm-integration.el --- LLM and MCP integration -*- lexical-binding: t; -*-

;;; Commentary:
;; gptel backends, tools, directives and MCP server wiring.

;;; Code:

(require 'gptel)
(require 'mcp)
(require 'gptel-integrations)
(require 'pass-integration)

(defun llm-integration-init ()
  "Configure gptel and MCP."
  (setq gptel-backend (gptel-make-deepseek "Deepseek"
                        :stream t
                        :key (lambda () (password-store-get-cached "dev/deepseek.com/key")))
        gptel-model 'deepseek-v4-flash
        gptel-use-tools t
        gptel-default-mode 'org-mode
        mcp-hub-servers '(("web" . (:url "http://localhost:5353/mcp"))))
  (add-hook 'gptel-mode-hook 'company-mode)
  (setf (alist-get 'default gptel-directives)
        "You are a large language model living in Emacs and a helpful assistant. Respond concisely.
Write Org Mode and NEVER Markdown as the output will be rendered inside an Emacs buffer and it must be valid Org Mode.")

  (add-hook 'after-init-hook
            (lambda ()
              (gptel-mcp-connect '("web")))))

(unless noninteractive
  (llm-integration-init))

(provide 'llm-integration)
;;; llm-integration.el ends here
