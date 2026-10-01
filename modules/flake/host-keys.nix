# Each enrolled machine's public SSH host key, from modules/hosts/_host-keys.json
# (written by `just secrets-enrol`). The one list behind the pinned
# known_hosts entries (ssh feature) and the sops recipients (.sops.yaml).
{ lib, ... }:
{
  options.hostKeys = lib.mkOption {
    type = lib.types.attrsOf (lib.types.strMatching "ssh-ed25519 [A-Za-z0-9+/=]+");
    readOnly = true;
    default = lib.importJSON ../hosts/_host-keys.json;
    description = "Enrolled machines' /etc/ssh/ssh_host_ed25519_key.pub, without the comment.";
  };
}
