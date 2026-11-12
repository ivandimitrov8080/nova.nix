{
  trivialBuild,
  gptel,
  gptel-agent,
  mcp,
  pass-integration,
  pkgs,
  ...
}:
trivialBuild {
  pname = "llm-integration";
  version = "0.1.0";
  src = ./llm-integration.el;
  packageRequires = [
    gptel
    gptel-agent
    mcp
    pass-integration
  ];
  propagatedUserEnvPkgs = [
    pkgs.mcp-server-fetch
    pkgs.mcp-server-filesystem
    pkgs.mcp-server-time
    pkgs.mcp-server-git
    pkgs.open-websearch
    pkgs.curl
  ];
}
