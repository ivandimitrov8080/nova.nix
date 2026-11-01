{
  trivialBuild,
  magit,
  diff-hl,
  pkgs,
  ...
}:
trivialBuild {
  pname = "git-workflow";
  version = "0.1.0";
  src = ./git-workflow.el;
  packageRequires = [
    magit
    diff-hl
  ];
  propagatedUserEnvPkgs = [ pkgs.git ];
}
