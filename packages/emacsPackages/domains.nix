# The domain packages, in load order. This is the single list: the Emacs
# package set (../emacsPackages/default.nix) and extraEmacsPackages
# (../emacs/default.nix) are both derived from it. Only emacs.el still spells
# out its (require ...) calls, because the order there is load order.
[
  "pass-integration"
  "editor-defaults"
  "ui-chrome"
  "completion-ui"
  "structural-editing"
  "llm-integration"
  "code-intelligence"
  "language-support"
  "git-workflow"
  "org-workflow"
  "media-playback"
  "messaging"
  "rss-feeds"
  "nix-tooling"
  "utility-commands"
]
