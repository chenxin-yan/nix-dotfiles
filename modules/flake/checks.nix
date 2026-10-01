# sops-nix only checks that a secrets file parses, so a plaintext file would
# pass its build. Fail `nix flake check` for any tracked file under secrets/
# that sops didn't encrypt.
{ lib, ... }:
let
  dir = ../../secrets;
  files = lib.optionals (builtins.pathExists dir) (lib.filesystem.listFilesRecursive dir);
  encrypted =
    file:
    let
      text = builtins.readFile file;
    in
    lib.hasInfix "\nsops:\n" text && lib.hasInfix "mac: ENC[" text;
  plaintext = map (f: lib.removePrefix (toString dir + "/") (toString f)) (
    lib.filter (f: !encrypted f) files
  );
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.secrets-encrypted = pkgs.runCommand "secrets-encrypted" { } (
        if plaintext == [ ] then
          "touch $out"
        else
          ''
            echo "not encrypted by sops: ${lib.concatStringsSep ", " plaintext}" >&2
            exit 1
          ''
      );
    };
}
