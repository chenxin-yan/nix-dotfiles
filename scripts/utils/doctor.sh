#!/usr/bin/env bash
# Read-only check that what Nix declares for this machine is in effect:
# enrolment, published secrets, the SSH agent and GitHub access. Run after
# onboarding or a switch:
#   just doctor
# Keep this runnable by macOS /bin/bash 3.2: no mapfile, arrays or ${var,,}.

set -uo pipefail

root="$(cd -P "$(dirname "$0")/../.." && pwd -P)"
failed=0
ok() { printf '  ✓ %s\n' "$1"; }
bad() { printf '  ✗ %s\n' "$1"; failed=1; }

case "$(uname -s)" in
  Darwin) kind=darwinConfigurations ;;
  *) kind=nixosConfigurations ;;
esac
target="$(hostname)"
target="${target%%.*}"

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

# Every declared secret is owned by the login, so each must be readable here.
secrets="$(nix eval --raw --no-update-lock-file "$root#$kind.$target.config" --apply 'cfg:
  builtins.concatStringsSep "\n" (map (s: s.path) (builtins.attrValues (cfg.sops.secrets or { })))' 2>/dev/null)"
while read -r path; do
  [ -n "$path" ] || continue
  if [ -r "$path" ]; then
    ok "secret $path is readable"
  else
    bad "secret $path is not readable; check sops-install-secrets in the last switch"
  fi
done <<EOF
$secrets
EOF

agent="$(ssh -G github.com 2>/dev/null | awk '$1 == "identityagent" { $1 = ""; sub(/^ /, ""); print }')"
case "$agent" in
  "" | none | SSH_AUTH_SOCK) ;;
  *)
    if [ ! -S "$agent" ]; then
      bad "no SSH agent socket at $agent; turn it on in 1Password → Settings → Developer"
    elif SSH_AUTH_SOCK="$agent" ssh-add -l >/dev/null 2>&1; then
      ok "1Password's SSH agent offers a key"
    else
      bad "1Password's SSH agent offers no keys; unlock 1Password and check ~/.config/1Password/ssh/agent.toml"
    fi
    ;;
esac

github="$(ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1)"
case "$github" in
  *"successfully authenticated"*) ok "GitHub accepts this machine's SSH key" ;;
  *) bad "GitHub rejects SSH: ${github%%$'\n'*}" ;;
esac

exit "$failed"
