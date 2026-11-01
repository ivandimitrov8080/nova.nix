{
  trivialBuild,
  catppuccin-theme,
  nerd-icons,
  nerd-icons-xref,
  nerd-icons-dired,
  nerd-icons-completion,
  nerd-icons-ibuffer,
  doom-modeline,
  inhibit-mouse,
  pkgs,
  ...
}:
trivialBuild {
  pname = "ui-chrome";
  version = "0.1.0";
  src = ./ui-chrome.el;
  packageRequires = [
    catppuccin-theme
    nerd-icons
    nerd-icons-xref
    nerd-icons-dired
    nerd-icons-completion
    nerd-icons-ibuffer
    doom-modeline
    inhibit-mouse
  ];
  propagatedUserEnvPkgs = [
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
    pkgs.noto-fonts-lgc-plus
  ];
}
