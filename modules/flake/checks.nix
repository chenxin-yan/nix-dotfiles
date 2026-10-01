# sops-nix only checks that a secrets file parses, so a plaintext file would
# pass its build. Fail `nix flake check` for any tracked file under secrets/
# that sops didn't encrypt.
{ lib, ... }:
let
  dir = ../../secrets;
  files = lib.filesystem.listFilesRecursive dir;
  encrypted = file: lib.hasInfix "mac: ENC[" (builtins.readFile file);
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
