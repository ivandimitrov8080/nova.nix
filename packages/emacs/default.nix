{
  emacs-unstable-pgtk,
  emacsWithPackagesFromUsePackage,
  ...
}:
emacsWithPackagesFromUsePackage {
  # Your Emacs config file. Org mode babel files are also
  # supported.
  # NB: Config files cannot contain unicode characters, since
  #     they're being parsed in nix, which lacks unicode
  #     support.
  config = ./emacs.el;

  # Whether to include your config as a default init file.
  # If being bool, the value of config is used.
  # Its value can also be a derivation like this if you want to do some
  # substitution:
  #   defaultInitFile = pkgs.substituteAll {
  #     name = "default.el";
  #     src = ./emacs.el;
  #     inherit (config.xdg) configHome dataHome;
  #   };
  defaultInitFile = true;

  # Package is optional, defaults to pkgs.emacs
  package = emacs-unstable-pgtk;

  # The domain packages are the whole configuration. Each one declares its own
  # Emacs dependencies and the runtime dependencies it owns (language servers,
  # linters, MCP servers, fonts, ...) via `propagatedUserEnvPkgs`, so nothing
  # executable is listed here.
  extraEmacsPackages = epkgs: map (name: epkgs.${name}) (import ../emacsPackages/domains.nix);
}
