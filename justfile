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
    nh clean all --optomize

# Format all nix files
fmt:
    treefmt

# Search for a package
search PACKAGE:
    nix search nixpkgs {{PACKAGE}}

# Show package information
show PACKAGE:
    nix-env -qa --description {{PACKAGE}}
