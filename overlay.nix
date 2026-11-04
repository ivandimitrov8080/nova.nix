{
  inputs,
  docsNixos,
}:
final: prev:
let
  inherit (final) callPackage lib;
  pkgs = final;
  emacsSrc = ./packages/emacs;
  emacsPackagesSrc = ./packages/emacsPackages;
in
{
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
      final: prev:
      import emacsPackagesSrc {
        inherit
          final
          prev
          lib
          pkgs
          ;
      }
    );
  docs-nixos = docsNixos;
}
