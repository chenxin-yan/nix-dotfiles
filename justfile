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

# Format all nix files
fmt:
    nix fmt

# Search for a package
search PACKAGE:
    nix search nixpkgs {{PACKAGE}}

# Show package information
show PACKAGE:
    nix-env -qa --description {{PACKAGE}}
