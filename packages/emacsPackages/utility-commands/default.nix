{
  trivialBuild,
  org,
  request,
  xterm-color,
  khalel,
  ddgr,
  pkgs,
  ...
}:
trivialBuild {
  pname = "utility-commands";
  version = "0.1.0";
  src = ./utility-commands.el;
  packageRequires = [
    org
    request
    xterm-color
    khalel
    ddgr
  ];
  propagatedUserEnvPkgs = [
    pkgs.askpass
    pkgs.tree
    pkgs.khal
    pkgs.openssh
    pkgs.ddgr
  ];
}
