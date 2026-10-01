{
  # Client only; NixOS hosts that accept mosh select mosh-server.
  features.mosh.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mosh ];
    };

  # TODO: remove once nixpkgs-unstable has NixOS/nixpkgs#568002 (merged into
  # master 2026-09-29), then `nix flake update nixpkgs`. Until then mosh 1.4.0
  # fails to build with GCC 16 against the current abseil; this mirrors that
  # fix. The Macs build with clang and are unaffected. The fix is in when this
  # prints "ahead" or "identical":
  #   gh api repos/NixOS/nixpkgs/compare/99e0646871b753b5ea8355e69dfdbd28f5ba3602...nixpkgs-unstable --jq .status
  # Also used by mosh-server, through the same pkgs.
  features.mosh.nixos.nixpkgs.overlays = [
    (final: prev: {
      mosh = prev.mosh.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.autoconf-archive ];
        # Superseded by the up-to-date macros from autoconf-archive.
        patches = builtins.filter (
          p: !(final.lib.hasInfix "eee1a8cf413051c2a9104e8158e699028ff56b26" (toString p))
        ) old.patches;
        # The bundled m4 directory holds ancient macros that pin C++17.
        postPatch = "rm -rf m4\n" + old.postPatch;
      });
    })
  ];
}
