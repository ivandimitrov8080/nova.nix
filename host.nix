{
  inputs,
}:
{
  pkgs,
  ...
}:
{
  imports = [ ./wireguard.nix ];

  meta = {
    host = {
      stateVersion = "26.05";
    };

    graphicalBoot.plymouthTheme = "/etc/plymouth/themes/catppuccin-mocha/catppuccin-mocha.plymouth";

    minimal = {
      enable = true;
      optionDocs = {
        nixos = pkgs.docs-nixos;
        homeManager = inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.docs-json;
      };
    };

    dns = {
      servers = [ "10.0.0.1" ];
      egress.restrict = true;
    };
  };
}
