#!/usr/bin/env bash
# Read-only check that what Nix declares for this machine is in effect:
# enrolment, published secrets, the SSH agent and GitHub access. Also points
# out files the dotfiles no longer use. Run after onboarding or a switch:
#   just doctor
# Keep this runnable by macOS /bin/bash 3.2: no mapfile, arrays or ${var,,}.

set -uo pipefail

root="$(cd -P "$(dirname "$0")/../.." && pwd -P)"
failed=0
ok() { printf '  ✓ %s\n' "$1"; }
bad() { printf '  ✗ %s\n' "$1"; failed=1; }
hint() { printf '  ! %s\n' "$1"; }

case "$(uname -s)" in
  Darwin) kind=darwinConfigurations ;;
  *) kind=nixosConfigurations ;;
esac
target="$(hostname)"
target="${target%%.*}"
login="$(id -un)"

registered="$(nix eval --raw --no-update-lock-file "$root#hosts" \
  --apply 'hosts: builtins.concatStringsSep " " (builtins.attrNames hosts)' 2>/dev/null)"
case " $registered " in
  *" $target "*) ok "$target is a registered target" ;;
  *)
    bad "$target is not a registered target (registered: $registered)"
    exit 1
    ;;
esac

hostkey=/etc/ssh/ssh_host_ed25519_key.pub
enrolled="$(jq -r --arg n "$target" '.[$n] // empty' "$root/modules/hosts/_host-keys.json")"
if [ ! -r "$hostkey" ]; then
  bad "no $hostkey; rerun bash scripts/onboard.sh"
elif [ "$(cut -d' ' -f1,2 "$hostkey")" = "$enrolled" ]; then
  ok "host key is enrolled"
else
  bad "host key is not the enrolled one; from a machine with 1Password: just secrets-enrol $target '$(cut -d' ' -f1,2 "$hostkey")'"
fi

# One "name path owner" line per declared secret.
# shellcheck disable=SC2016
secrets="$(nix eval --raw --no-update-lock-file "$root#$kind.$target.config" --apply 'cfg:
  builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
    (n: s: "${n} ${s.path} ${if s.owner == null then "root" else s.owner}") (cfg.sops.secrets or { })))' 2>/dev/null)"
while read -r name path owner; do
  [ -n "$name" ] || continue
  if [ "$owner" = "$login" ] && [ -r "$path" ]; then
    ok "secret $name is readable at $path"
  elif [ "$owner" != "$login" ] && [ -e "$path" ]; then
    ok "secret $name is published at $path (owner $owner)"
  else
    bad "secret $name is missing at $path; check sops-install-secrets in the last switch"
  fi
done <<EOF
$secrets
EOF

agent="$(ssh -G github.com 2>/dev/null | awk '$1 == "identityagent" { $1 = ""; sub(/^ /, ""); print }')"
agent="${agent%\"}"
agent="${agent#\"}"
case "$agent" in
  "" | none | SSH_AUTH_SOCK) ;;
  *)
    agent="${agent/#\~/$HOME}"
    if [ ! -S "$agent" ]; then
      bad "no SSH agent socket at $agent; turn it on in 1Password → Settings → Developer"
    elif SSH_AUTH_SOCK="$agent" ssh-add -l >/dev/null 2>&1; then
      ok "1Password's SSH agent offers a key"
    else
      bad "1Password's SSH agent offers no keys; unlock 1Password and check ~/.config/1Password/ssh/agent.toml"
    fi
    [ ! -e "$HOME/.ssh/id_ed25519" ] \
      || hint "$HOME/.ssh/id_ed25519 is unused here (ssh uses the agent); delete it and its GitHub key once the agent works"
    ;;
esac

github="$(ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1)"
case "$github" in
  *"successfully authenticated"*) ok "GitHub accepts this machine's SSH key" ;;
  *) bad "GitHub rejects SSH: ${github%%$'\n'*}" ;;
esac

for old in "$HOME/.env" "$HOME/.config/pi/firecrawl-api-key" "$HOME/.config/nia/api_key"; do
  [ ! -e "$old" ] || hint "$old is no longer used (keys come from sops); delete it"
done

exit "$failed"
