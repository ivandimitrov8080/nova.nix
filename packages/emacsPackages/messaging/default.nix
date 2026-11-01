{
  trivialBuild,
  notmuch,
  telega,
  code-intelligence,
  pass-integration,
  media-playback,
  pkgs,
  ...
}:
trivialBuild {
  pname = "messaging";
  version = "0.1.0";
  src = ./messaging.el;
  packageRequires = [
    notmuch
    telega
    code-intelligence
    pass-integration
    media-playback
  ];
  propagatedUserEnvPkgs = [
    pkgs.notmuch
    pkgs.msmtp
    pkgs.gnupg
    pkgs.libwebp
  ];
}
