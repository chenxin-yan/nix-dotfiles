# justfile for dotfiles management
# Run `just` or `just --list` to see all available commands

# Default recipe - list all available commands
default:
    @just --list

# Rebuild and switch this host's registered configuration; TARGET only for one-time bootstrap
switch TARGET='':
    {{ quote(justfile_directory() / "scripts/utils/switch.sh") }} {{ if TARGET == '' { '' } else { quote(TARGET) } }}

# Update flake inputs
update:
    nix flake update

# Update pinned fetchFromGitHub dependencies to latest
update-pins *ARGS:
    ./scripts/utils/update-pins.sh {{ARGS}}

# Clean up old generations and garbage collect
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -s)" in Darwin) kind=darwin ;; *) kind=nixos ;; esac
    # Retention is this host's nix.gc.options, set by the nix-gc feature.
    args=$(nix eval --raw {{ quote(justfile_directory()) }}"#${kind}Configurations.$(hostname).config.nix.gc.options")
    sudo -- "$(command -v nix-collect-garbage)" $args
    sudo -- "$(command -v nix-store)" --optimise

# sops reads the recovery key from 1Password whenever it needs one; nothing
# is written to disk. Any enrolled host key works for decryption too, but
# only root can read those.
export SOPS_AGE_KEY_CMD := "op document get sops-recovery"

# Set one secret from a hidden prompt (FILE: secrets/shared.yaml or secrets/hosts/<host>.yaml)
secret-set NAME FILE='secrets/shared.yaml':
    #!/usr/bin/env bash
    set -euo pipefail
    name={{ quote(NAME) }} file={{ quote(FILE) }}
    [[ $name =~ ^[a-z0-9_-]+$ ]] || { echo "secret names use a-z, 0-9, _ and -" >&2; exit 1; }
    if [ ! -e "$file" ]; then
      mkdir -p "$(dirname "$file")"
      printf '{}\n' > "$file"
      sops encrypt --in-place "$file"
    fi
    read -rsp "Value for $name: " value; echo
    # JSON on stdin keeps the value out of argv and shell history.
    printf '%s' "$value" | jq -Rs . | sops set --value-stdin "$file" "[\"$name\"]"
    echo "Set $name in $file. Commit it, then switch the hosts that use it."

# Edit an encrypted file in $EDITOR (sops keeps a plaintext temp copy while it is open)
secrets-edit FILE='secrets/shared.yaml':
    sops edit {{ quote(FILE) }}

# Re-encrypt every secrets file for the recipients now in .sops.yaml
secrets-rekey:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    # updatekeys doesn't search folders, so every file is named here.
    for file in secrets/*.yaml secrets/hosts/*.yaml; do
      sops updatekeys --yes "$file"
    done

# Format all nix files
fmt:
    nix fmt

# Search for a package
search PACKAGE:
    nix search nixpkgs {{PACKAGE}}

# Show package information
show PACKAGE:
    nix-env -qa --description {{PACKAGE}}
