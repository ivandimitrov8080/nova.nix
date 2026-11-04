{
  emacs-unstable-pgtk,
  emacsWithPackagesFromUsePackage,
  ...
}:
emacsWithPackagesFromUsePackage {
  config = ./emacs.el;
  defaultInitFile = true;
  package = emacs-unstable-pgtk;
  extraEmacsPackages = epkgs: map (name: epkgs.${name}) (import ../emacsPackages/domains.nix);
}
