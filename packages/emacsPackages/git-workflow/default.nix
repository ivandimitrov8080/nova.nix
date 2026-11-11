{
  trivialBuild,
  magit,
  forge,
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
    forge
    diff-hl
  ];
  propagatedUserEnvPkgs = [ pkgs.git ];
}
