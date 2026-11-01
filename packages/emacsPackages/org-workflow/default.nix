{
  trivialBuild,
  org,
  org-modern,
  valign,
  org-appear,
  mixed-pitch,
  olivetti,
  ob-nix,
  markdown-mode,
  htmlize,
  pkgs,
  ...
}:
trivialBuild {
  pname = "org-workflow";
  version = "0.1.0";
  src = ./org-workflow.el;
  packageRequires = [
    org
    org-modern
    valign
    org-appear
    mixed-pitch
    olivetti
    ob-nix
    markdown-mode
    htmlize
  ];
  propagatedUserEnvPkgs = [
    pkgs.pandoc
    pkgs.discount
    pkgs.bash
    pkgs.nix
    # Python for `:python` Babel blocks is the environment provided by
    # llm-integration, so it is not duplicated here.
  ];
}
