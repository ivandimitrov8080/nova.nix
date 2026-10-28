# Everything host specific about the laptop: which option docs, which
# wireguard identity and where DNS goes. The baseline lives in
# configuration.nix's meta.{host,minimal,wireguard,dns} modules.
{
  inputs,
}:
{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./peers.nix ];

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

    wireguard = {
      enable = true;
      self = "nova";
      address = "10.0.0.2/24";
    };

    dns = {
      # the hub is the only resolver this host may talk to
      servers = [ config.meta.wireguard.peers.hub.ip ];
      egress.restrict = true;
    };
  };
}
