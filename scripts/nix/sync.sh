#!/usr/bin/env bash

detect_platform() {
    case "$(uname -s)" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            if [ -f /etc/os-release ] && grep -q "^ID=nixos" /etc/os-release; then
                echo "nixos"
            else
                echo "unknown"
            fi
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
        nixos)
            if ! command -v nix &> /dev/null; then
                missing_deps+=("nix")
            fi
            if ! command -v nixos-rebuild &> /dev/null; then
                missing_deps+=("nixos-rebuild")
            fi
            ;;
    esac

    if [ ${#missing_deps[@]} -gt 0 ]; then
        gum log --level error "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Function to run the appropriate switch command
run_switch() {
    local platform=$1
    local dotfiles_path=$2
    local switch_exit_code=0
    
    # Prompt for sudo password if needed
    if ! sudo -n true 2>/dev/null; then
        gum log --level info "Administrative privileges required"
        gum input --password --placeholder "Enter sudo password" | sudo -S true 2>/dev/null
        if [ $? -ne 0 ]; then
            gum log --level error "Authentication failed"
            return 1
        fi
    fi
    
    case $platform in
        darwin)
            gum log --level info "Switching nix-darwin configuration..."
            sudo darwin-rebuild switch --flake "$dotfiles_path#yanchenxin@darwin"
            switch_exit_code=$?
            ;;
        nixos)
            gum log --level info "Switching NixOS configuration..."
            sudo nixos-rebuild switch --flake "$dotfiles_path#cyan@nixos"
            switch_exit_code=$?
            ;;
        *)
            gum log --level error "Unsupported platform: $platform"
            return 1
            ;;
    esac
    
    return $switch_exit_code
}

# Main function
main() {
    # Use DOTFILES_PATH environment variable
    local dotfiles_path="${DOTFILES_PATH:-}"
    
    if [ -z "$dotfiles_path" ]; then
        gum log --level error "DOTFILES_PATH environment variable is not set"
        exit 1
    fi
    
    # Display header
    gum style \
        --border double \
        --align center --width 50 --margin "1 2" --padding "1 4" \
        "Nix Configuration Sync"
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    
    gum log --level info "Detected platform: $platform"
    
    if [ "$platform" = "unknown" ]; then
        gum log --level error "Unsupported platform detected"
        exit 1
    fi
    
    # Validate and change to dotfiles directory
    if [ ! -d "$dotfiles_path" ]; then
        gum log --level error "Directory does not exist: $dotfiles_path"
        exit 1
    fi
    
    if [ ! -f "$dotfiles_path/flake.nix" ]; then
        gum log --level error "flake.nix not found in: $dotfiles_path"
        exit 1
    fi
    
    gum log --level info "Using dotfiles path: $dotfiles_path"
    cd "$dotfiles_path" || exit 1
    
    # Check dependencies
    if ! check_dependencies "$platform"; then
        exit 1
    fi
    
    # Run the switch
    if run_switch "$platform" "$dotfiles_path"; then
        echo
        gum log --level info "✓ Configuration switch completed successfully!"
    else
        echo
        gum log --level error "Configuration switch failed! Check the output above for details."
        exit 1
    fi
}

# Run main function
main
