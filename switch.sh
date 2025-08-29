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
    case "$(uname -s)" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            echo "linux"
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
            if ! command -v darwin-rebuild &> /dev/null; then
                if ! command -v nix &> /dev/null; then
                    missing_deps+=("nix")
                else
                    print_warning "darwin-rebuild not found. Will attempt first-time setup."
                fi
            fi
            ;;
        linux)
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
    
    print_status "Switching configuration for $platform..."
    
    case $platform in
        darwin)
            if command -v darwin-rebuild &> /dev/null; then
                print_status "Running darwin-rebuild switch..."
                darwin-rebuild switch --flake ".#chenxinyan@darwin"
            else
                print_status "First-time nix-darwin setup..."
                print_warning "This will require sudo permissions for initial setup."
                nix run nix-darwin -- switch --flake ".#chenxinyan@darwin"
                print_success "nix-darwin installed! Future runs will use darwin-rebuild."
            fi
            ;;
        linux)
            print_status "Running home-manager switch..."
            home-manager switch --flake ".#chenxinyan@linux"
            ;;
        *)
            print_error "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# Main function
main() {
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
    
    # Check if we're in the right directory
    if [ ! -f "flake.nix" ]; then
        print_error "flake.nix not found. Please run this script from your dotfiles directory."
        exit 1
    fi
    
    # Check dependencies
    if ! check_dependencies "$platform"; then
        exit 1
    fi
    
    # Run the switch
    if run_switch "$platform"; then
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
