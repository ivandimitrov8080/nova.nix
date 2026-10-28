{
  inputs = {
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    configuration.url = "github:ivandimitrov8080/configuration.nix";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neomacs.url = "github:eval-exec/neomacs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      # Build option docs from a separate, host-neutral evaluation. Reusing
      # `self.nixosConfigurations.default` would make the overlay depend on the
      # very configuration that consumes it.
      docsConfig = nixpkgs.lib.nixosSystem {
        modules = [
          inputs.configuration.nixosModules.default
          inputs.home-manager.nixosModules.default
          { nixpkgs.hostPlatform = "x86_64-linux"; }
        ];
      };
      docsNixos = docsConfig.config.system.build.manual.optionsJSON;
      novaOverlay = import ./overlay.nix { inherit inputs docsNixos; };

      host = nixpkgs.lib.nixosSystem {
        # meta.host.* reads the flake inputs from here.
        specialArgs = { inherit inputs; };
        modules = [
          inputs.configuration.nixosModules.default
          inputs.home-manager.nixosModules.default
          (import ./host.nix { inherit inputs; })
          (import ./rest.nix { inherit inputs; })
          (import ./machine.nix { inherit inputs; })
          {
            nixpkgs = {
              hostPlatform = "x86_64-linux";
              overlays = [
                inputs.emacs-overlay.overlays.default
                novaOverlay
                inputs.configuration.overlays.default
              ];
            };
            nix.registry = {
              self.flake = inputs.self;
              nixpkgs.flake = inputs.nixpkgs;
              p.flake = inputs.nixpkgs;
            };
          }
        ];
      };
    in
    {
      nixosConfigurations.default = host;

      checks.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.runCommand "eval-nova" { } ''
        echo ${builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath} > $out
      '';
    };
}
