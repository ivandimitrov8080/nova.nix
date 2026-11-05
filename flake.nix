{
  inputs = {
    configuration.url = "git://idimitrov.dev/configuration.nix";
    nixpkgs.url = "git://idimitrov.dev/nixpkgs/nixos-unstable";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      docsConfig = nixpkgs.lib.nixosSystem {
        modules = [
          inputs.configuration.nixosModules.default
          inputs.home-manager.nixosModules.default
          { nixpkgs.hostPlatform = "x86_64-linux"; }
        ];
      };
      docsNixos = docsConfig.config.system.build.manual.optionsJSON;
      novaOverlay = import ./overlay.nix { inherit inputs docsNixos; };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          inputs.emacs-overlay.overlays.default
          novaOverlay
          inputs.configuration.overlays.default
        ];
      };

      host = nixpkgs.lib.nixosSystem {
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
      nixosConfigurations.nova = host;
      packages.x86_64-linux.emacs = pkgs.emacs-custom;
    };
}
