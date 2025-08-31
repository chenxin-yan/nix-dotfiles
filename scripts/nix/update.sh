#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to update flake
update_flake() {
    local dotfiles_path=$1
    
    print_status "Updating nix flake..."
    cd "$dotfiles_path"
    
    if nix flake update; then
        print_success "Flake updated successfully"
    else
        print_error "Failed to update flake"
        return 1
    fi
}

# Function to get fresh hash from GitHub
get_github_hash() {
    local owner=$1
    local repo=$2
    local rev=$3
    
    print_status "Fetching hash for $owner/$repo@$rev..."
    
    local hash
    hash=$(nix run nixpkgs#nix-prefetch-github -- --owner "$owner" --repo "$repo" --rev "$rev" 2>/dev/null | grep sha256 | cut -d'"' -f4)
    
    if [ -z "$hash" ]; then
        print_error "Failed to fetch hash for $owner/$repo@$rev"
        return 1
    fi
    
    echo "$hash"
}

# Function to update hash in file
update_hash_in_file() {
    local file_path=$1
    local old_hash=$2
    local new_hash=$3
    
    if [ "$old_hash" = "$new_hash" ]; then
        print_status "Hash unchanged for this plugin"
        return 0
    fi
    
    print_status "Updating hash from $old_hash to $new_hash"
    
    if sed -i.bak "s|$old_hash|$new_hash|g" "$file_path"; then
        rm "$file_path.bak"
        print_success "Hash updated successfully"
    else
        print_error "Failed to update hash in file"
        return 1
    fi
}

# Function to update yazi plugin hashes
update_yazi_hashes() {
    local dotfiles_path=$1
    local yazi_config="$dotfiles_path/modules/shared/core/yazi/default.nix"
    
    if [ ! -f "$yazi_config" ]; then
        print_error "Yazi config not found: $yazi_config"
        return 1
    fi
    
    print_status "Updating yazi plugin hashes..."
    
    # Extract current hashes
    local yazi_plugins_hash
    local omp_hash
    
    yazi_plugins_hash=$(grep -A3 'owner = "yazi-rs"' "$yazi_config" | grep 'hash = ' | cut -d'"' -f2)
    omp_hash=$(grep -A3 'owner = "saumyajyoti"' "$yazi_config" | grep 'hash = ' | cut -d'"' -f2)
    
    if [ -z "$yazi_plugins_hash" ] || [ -z "$omp_hash" ]; then
        print_error "Could not extract current hashes from yazi config"
        return 1
    fi
    
    print_status "Current yazi-plugins hash: $yazi_plugins_hash"
    print_status "Current omp hash: $omp_hash"
    
    # Get new hashes
    local new_yazi_plugins_hash
    local new_omp_hash
    
    new_yazi_plugins_hash=$(get_github_hash "yazi-rs" "plugins" "main")
    new_omp_hash=$(get_github_hash "saumyajyoti" "omp.yazi" "main")
    
    # Update hashes in file
    update_hash_in_file "$yazi_config" "$yazi_plugins_hash" "$new_yazi_plugins_hash"
    update_hash_in_file "$yazi_config" "$omp_hash" "$new_omp_hash"
}

# Main function
main() {
    # Use DOTFILES_PATH environment variable
    local dotfiles_path="${DOTFILES_PATH:-}"
    
    if [ -z "$dotfiles_path" ]; then
        print_error "DOTFILES_PATH environment variable is not set"
        exit 1
    fi
    
    print_status "Nix Update Script"
    echo
    
    # Validate dotfiles directory
    if [ ! -d "$dotfiles_path" ]; then
        print_error "Directory does not exist: $dotfiles_path"
        exit 1
    fi
    
    if [ ! -f "$dotfiles_path/flake.nix" ]; then
        print_error "flake.nix not found in: $dotfiles_path"
        exit 1
    fi
    
    print_status "Using dotfiles path: $dotfiles_path"
    
    # Check if nix is available
    if ! command -v nix &> /dev/null; then
        print_error "nix command not found"
        exit 1
    fi
    
    # Update flake
    if ! update_flake "$dotfiles_path"; then
        exit 1
    fi
    
    echo
    
    # Update yazi plugin hashes
    if ! update_yazi_hashes "$dotfiles_path"; then
        exit 1
    fi
    
    echo
    print_success "Update completed successfully!"
    print_status "You can now run 'scripts/nix/sync.sh' to apply the changes"
}

# Run main function
main
