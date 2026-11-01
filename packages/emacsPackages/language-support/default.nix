{
  trivialBuild,
  nix-mode,
  nix-ts-mode,
  rust-mode,
  elm-mode,
  haskell-ts-mode,
  nushell-mode,
  typst-ts-mode,
  markdown-mode,
  yaml-mode,
  eglot,
  company,
  treesit-grammars,
  pkgs,
  ...
}:
trivialBuild {
  pname = "language-support";
  version = "0.1.0";
  src = ./language-support.el;
  packageRequires = [
    nix-mode
    nix-ts-mode
    rust-mode
    elm-mode
    haskell-ts-mode
    nushell-mode
    typst-ts-mode
    markdown-mode
    yaml-mode
    eglot
    company
    treesit-grammars.with-all-grammars
  ];
  propagatedUserEnvPkgs = [
    pkgs.nixd
    pkgs.elmPackages.elm-language-server
    pkgs.elmPackages.elm-format
    pkgs.haskell-language-server
    pkgs.typescript-language-server
    pkgs.vscode-html-languageserver
    pkgs.vscode-css-languageserver
    pkgs.nushell
    pkgs.tinymist
    pkgs.typst
    pkgs.rust-analyzer
    pkgs.python3Packages.python-lsp-server
    (pkgs.ghc.withPackages (
      hp: with hp; [
        notmuch
        mime
        hp.pandoc
        zlib
        Glob
        extra
        tar
      ]
    ))
  ];
}
