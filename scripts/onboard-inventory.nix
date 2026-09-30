# Registered targets for scripts/onboard.sh, one "name system login" line
# each. Read from the host files directly rather than through the flake, so
# a host file written by an earlier wizard run but not yet tracked by Git
# still counts. Host files are flake-parts modules: each is called with empty
# stand-ins for the module arguments it names, and only `system` and `login`
# are forced.
{ dir }:
let
  root = if builtins.isPath dir then dir else /. + dir;
  entries = builtins.readDir root;
  file = n: if entries.${n} == "directory" then root + "/${n}/default.nix" else root + "/${n}";
  isHost =
    n:
    builtins.match "_.*" n == null
    && (
      if entries.${n} == "directory" then
        builtins.pathExists (file n)
      else
        builtins.match ".*\\.nix" n != null
    );
  standIns = {
    config = {
      features = { };
      hosts = { };
    };
    inputs = { };
    lib = { };
  };
  load =
    n:
    let
      m = import (file n);
    in
    (
      if builtins.isFunction m then m (builtins.intersectAttrs (builtins.functionArgs m) standIns) else m
    ).hosts or { };
in
builtins.concatStringsSep "" (
  builtins.concatMap (
    n:
    let
      h = load n;
    in
    map (k: "${k} ${h.${k}.system} ${h.${k}.login}\n") (builtins.attrNames h)
  ) (builtins.filter isHost (builtins.attrNames entries))
)
