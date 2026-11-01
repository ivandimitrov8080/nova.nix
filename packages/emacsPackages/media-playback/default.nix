{
  trivialBuild,
  emms,
  transmission,
  pkgs,
  ...
}:
trivialBuild {
  pname = "media-playback";
  version = "0.1.0";
  src = ./media-playback.el;
  packageRequires = [
    emms
    transmission
  ];
  propagatedUserEnvPkgs = [
    pkgs.mpv
    pkgs.exiftool
    pkgs.libwebp
  ];
}
