# op: unlocks through the 1Password app where there is one, otherwise with
# `op signin`. The `just secret*` recipes read the sops recovery key with it.
let
  cli.programs._1password.enable = true;
in
{
  features._1password-cli = {
    darwin = cli;
    nixos = cli;
  };
}
