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
      modules = import ./modules.nix {
        inherit inputs;
        hostOverlays = [ (import ./overlay.nix { inherit inputs docsConfig; }) ];
      };
    in
    {
      nixosConfigurations.nova = nixpkgs.lib.nixosSystem {
        modules = [
          modules.default
          modules.minimal
          modules.wg
          (import ./rest.nix { inherit inputs; })
          (import ./machine.nix { inherit inputs; })
        ];
      };
    };
}
