{
  final,
  prev,
  lib,
  pkgs,
}:
let
  domains = import ./domains.nix;
in
lib.recurseIntoAttrs (
  lib.genAttrs domains (name: final.callPackage (./. + "/${name}") { inherit pkgs; })
  // {
    haskell-ts-mode = final.callPackage ./haskell-ts-mode { inherit prev; };
    vertico-nixos-options = final.callPackage ./vertico-nixos-options { };
  }
)
