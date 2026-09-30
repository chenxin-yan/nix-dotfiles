# `nix fmt` and `nix flake check`. The host checks only force evaluation
# (they record the system's drvPath), so they are cheap and catch broken
# configurations on the host's own platform; `nix flake check` does not
# know darwinConfigurations by itself.
{
  config,
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    {
      formatter = pkgs.nixfmt-tree;

      checks =
        lib.mapAttrs'
          (
            name: cfg:
            lib.nameValuePair "eval-${name}" (
              pkgs.writeText "eval-${name}" (
                builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath
              )
            )
          )
          (
            lib.filterAttrs (name: _: config.hosts.${name}.system == system) (
              config.flake.darwinConfigurations // config.flake.nixosConfigurations
            )
          )
        // {
          # The onboarding wizard's lifecycle tests; Nix and system tools are stubbed.
          onboard = pkgs.runCommand "onboard-test" { nativeBuildInputs = [ pkgs.git ]; } ''
            bash ${inputs.self}/scripts/onboard.test.sh
            touch $out
          '';
        };
    };
}
