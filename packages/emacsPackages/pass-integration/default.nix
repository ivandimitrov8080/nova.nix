{
  trivialBuild,
  pass,
  sops,
  pkgs,
  ...
}:
trivialBuild {
  pname = "pass-integration";
  version = "0.1.0";
  src = ./pass-integration.el;
  packageRequires = [
    pass
    sops
  ];
  propagatedUserEnvPkgs = [
    pkgs.pass
    pkgs.sops
  ];
}
