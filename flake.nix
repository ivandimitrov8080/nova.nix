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
    # the code shared by all hosts lives in the hosts.nix repo
    # src.url = "github:ivandimitrov8080/hosts.nix?dir=src";
    src = {
      url = "git+file:///home/ivand/src/hosts.nix?dir=src";
      flake = false;
    };
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      docsConfig = self.nixosConfigurations.nova;
      overlays = import (inputs.src + "/overlays.nix") { inherit inputs docsConfig; };
      nixosModules = import (inputs.src + "/modules") { inherit inputs overlays; };
    in
    {
      nixosConfigurations.nova = nixpkgs.lib.nixosSystem {
        modules = with nixosModules; [
          default
          minimal
          wg
          (import ./rest.nix {
            inherit inputs;
            src = inputs.src;
          })
          (import ./machine.nix { inherit inputs; })
        ];
      };
    };
}
