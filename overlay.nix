# nova-specific overlay. Everything here needs either a flake input or the
# evaluated host configuration, so it cannot live in the shared
# configuration.nix overlay (src/packages/overlay.nix), which only sees
# final/prev.
{ inputs, docsConfig }:
final: prev:
let
  # resolve dependencies from `final` so that packages from the other overlays
  # (configuration.nix, emacs-overlay) are visible here, not just base nixpkgs
  inherit (final) callPackage lib;
  emacsSrc = ./packages/emacs;
  emacsPackagesSrc = ./packages/emacsPackages;
in
{
  docs-nixos = docsConfig.config.system.build.manual.optionsJSON;
  docs-hm = inputs.home-manager.packages.${prev.stdenv.hostPlatform.system}.docs-json;
  which-key = callPackage ./packages/which-key { };
  emacs-custom = callPackage emacsSrc { inherit inputs; };
  neomacs = callPackage emacsSrc {
    inherit inputs;
    emacs-unstable-pgtk =
      inputs.neomacs.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs
        (old: {
          meta.platforms = final.emacs-unstable-pgtk.meta.platforms;
          passthru = (old.passthru or { }) // {
            withTreeSitter = true;
          };
          postInstall = (old.postInstall or "") + ''
            mkdir -p "$out/nix-support"
            cat ${final.emacs-unstable-pgtk}/nix-support/setup-hook >> "$out/nix-support/setup-hook"
          '';
        });
  };
  emacsPackagesFor =
    emacs:
    (prev.emacsPackagesFor emacs).overrideScope (
      final: prev: import emacsPackagesSrc { inherit final prev lib; }
    );
}
