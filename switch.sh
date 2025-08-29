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

# Function to detect platform
detect_platform() {
    local os arch
    
    case "$(uname -s)" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            case "$(uname -m)" in
                x86_64|amd64)
                    echo "linux-x86_64"
                    ;;
                aarch64|arm64)
                    echo "linux-arm64"
                    ;;
                *)
                    echo "unknown"
                    ;;
            esac
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to check if required commands exist
check_dependencies() {
    local platform=$1
    local missing_deps=()

    case $platform in
        darwin)
            if ! command -v nix &> /dev/null; then
                missing_deps+=("nix")
            fi
            if ! command -v darwin-rebuild &> /dev/null; then
                missing_deps+=("nix-darwin")
            fi
            ;;
        linux-*)
            if ! command -v nix &> /dev/null; then
                missing_deps+=("nix")
            fi
            if ! command -v home-manager &> /dev/null; then
                missing_deps+=("home-manager")
            fi
            ;;
    esac

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Function to run the appropriate switch command
run_switch() {
    local platform=$1
    local dotfiles_path=$2
    
    print_status "Switching configuration for $platform..."
    
    case $platform in
        darwin)
            print_status "Running darwin-rebuild switch..."
            sudo darwin-rebuild switch --flake "$dotfiles_path#chenxinyan@darwin"
            ;;
        linux-x86_64)
            print_error "Unsupported platform: $platform"
            return 1
            ;;
        linux-arm64)
            print_status "Running home-manager switch for Linux ARM64..."
            home-manager switch --flake "$dotfiles_path#chenxinyan@linux-arm64"
            ;;
        *)
            print_error "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# Main function
main() {
    local dotfiles_path="${1:-$(pwd)}"
    
    print_status "Platform-agnostic Nix configuration switcher"
    echo
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    
    print_status "Detected platform: $platform"
    
    if [ "$platform" = "unknown" ]; then
        print_error "Unsupported platform detected"
        exit 1
    fi
    
    # Validate and change to dotfiles directory
    if [ ! -d "$dotfiles_path" ]; then
        print_error "Directory does not exist: $dotfiles_path"
        exit 1
    fi
    
    if [ ! -f "$dotfiles_path/flake.nix" ]; then
        print_error "flake.nix not found in: $dotfiles_path"
        exit 1
    fi
    
    print_status "Using dotfiles path: $dotfiles_path"
    cd "$dotfiles_path"
    
    # Check dependencies
    if ! check_dependencies "$platform"; then
        exit 1
    fi
    
    # Run the switch
    if run_switch "$platform" "$dotfiles_path"; then
        echo
        print_success "Configuration switch completed successfully!"
    else
        echo
        print_error "Configuration switch failed!"
        exit 1
    fi
}

# Run main function
main "$@"
