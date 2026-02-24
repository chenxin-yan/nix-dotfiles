# justfile for dotfiles management
# Run `just` or `just --list` to see all available commands

# Default recipe - list all available commands
default:
    @just --list

# Darwin-specific recipes

# Rebuild and switch darwin configuration
[macos]
switch:
    nh darwin switch --hostname yanchenxin@darwin .

# Rebuild and switch nixos configuration
[linux]
switch:
    nh os switch --hostname cyan@nixos .

# Switch home-manager configuration (standalone)
home:
    home-manager switch --flake .

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
