# The `claude setup-token` subscription token, shared by every machine's
# agents through secrets/shared.yaml. It lasts a year; to rotate, rerun
# `claude setup-token` and `just secret-set claude-oauth-token`.
{
  declareSecret =
    { host, ... }:
    {
      sops.secrets.claude-oauth-token.owner = host.login;
    };

  # Reads the token at launch, which keeps it out of the store and out of
  # every shell's environment: only the program and its children see it.
  wrap =
    { pkgs, osConfig }:
    var: pkg:
    pkgs.symlinkJoin {
      inherit (pkg) name meta;
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pkg.meta.mainProgram} \
          --run 'export ${var}="$(<${osConfig.sops.secrets.claude-oauth-token.path})"'
      '';
    };
}
