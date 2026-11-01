{
  trivialBuild,
  company,
  flycheck,
  flycheck-aspell,
  fancy-compilation,
  tree-sitter,
  projectile,
  dired-quick-sort,
  vterm,
  llm-integration,
  pkgs,
  ...
}:
trivialBuild {
  pname = "code-intelligence";
  version = "0.1.0";
  src = ./code-intelligence.el;
  packageRequires = [
    company
    flycheck
    flycheck-aspell
    fancy-compilation
    tree-sitter
    projectile
    dired-quick-sort
    vterm
    llm-integration
  ];
  propagatedUserEnvPkgs = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.git
    pkgs.bash
    (pkgs.aspellWithDicts (
      d: with d; [
        en
        bg
      ]
    ))
  ];
}
