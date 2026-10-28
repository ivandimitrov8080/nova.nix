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
    inputs@{ self, nixpkgs, ... }:
    let
      docsConfig = self.nixosConfigurations.nova;
      novaOverlay = import ./overlay.nix { inherit inputs docsConfig; };
    in
    {
      nixosConfigurations.nova = nixpkgs.lib.nixosSystem {
        # meta.host.* reads the flake inputs from here.
        specialArgs = { inherit inputs; };
        modules = [
          inputs.configuration.nixosModules.default
          inputs.home-manager.nixosModules.default
          (import ./host.nix { inherit inputs novaOverlay; })
          (import ./rest.nix { inherit inputs; })
          (import ./machine.nix { inherit inputs; })
        ];
      };
    };
}
