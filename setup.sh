#!/bin/bash

# HyDE Custom Dotfiles Installation Script
# Author: hellia-be
# Description: Automated installation of custom HyDE configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root (except for the final sudo command)"
fi

# Function to clone or pull git repository
clone_or_pull() {
    local repo_url="$1"
    local target_dir="$2"
    local clone_args="${3:-}"
    
    if [[ -d "$target_dir/.git" ]]; then
        log "Repository $target_dir already exists. Pulling latest changes..."
        cd "$target_dir"
        git pull
        cd - > /dev/null
    else
        log "Cloning repository to $target_dir..."
        if [[ -d "$target_dir" ]]; then
            warn "Directory $target_dir exists but is not a git repository. Creating backup..."
            mv "$target_dir" "${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        git clone $clone_args "$repo_url" "$target_dir"
    fi
}

# Phase 1: Clone repositories and install HyDE
phase1() {
    log "=== Phase 1: Cloning repositories and installing HyDE ==="
    
    # Clone or pull custom dotfiles repository
    clone_or_pull "https://github.com/hellia-be/dotfiles" "$HOME/hyde-custom"
    
    # Clone or pull HyDE repository
    clone_or_pull "https://github.com/HyDE-Project/HyDE" "$HOME/HyDE" "--depth 1"
    
    # Copy custom package lists
    log "Copying custom package lists..."
    cd "$HOME/HyDE/Scripts"
    cp "$HOME/hyde-custom/HyDE/Scripts/pkg_user.lst" ./
    cp "$HOME/hyde-custom/HyDE/Scripts/pkg_core.lst" ./
    
    # Install HyDE
    log "Installing HyDE..."
    ./install.sh pkg_user.lst
    
    log "=== Phase 1 Complete ==="
    echo
    warn "IMPORTANT: You need to:"
    warn "1. Log out and log back in (or reboot)"
    warn "2. Change HyDE theme to 'Tokyo Night' from the Waybar"
    warn "3. Run this script again with the --phase2 flag"
    echo
    log "To continue after reboot, run: $0 --phase2"
}

# Phase 2: Apply custom configuration
phase2() {
    log "=== Phase 2: Applying custom configuration ==="
    
    # Check if hyde-custom directory exists
    if [[ ! -d "$HOME/hyde-custom" ]]; then
        error "hyde-custom directory not found. Please run phase 1 first."
    fi
    
    cd "$HOME"
    
    # Create necessary directories if they don't exist
    log "Creating necessary directories..."
    mkdir -p .config/fastfetch/logo/
    mkdir -p .config/hyde/themes/Tokyo\ Night/wallpapers/
    mkdir -p .config/hypr/themes/
    mkdir -p .local/share/hypr/
    mkdir -p .local/share/waybar/layouts/
    mkdir -p .local/share/waybar/modules/
    mkdir -p .local/state/hyde/
    
    # Copy configuration files
    log "Copying fastfetch logo files..."
    cp hyde-custom/.config/fastfetch/logo/* .config/fastfetch/logo/
    
    log "Copying Tokyo Night wallpaper..."
    cp "hyde-custom/.config/hyde/themes/Tokyo Night/wallpapers/gaming_room.gif" ".config/hyde/themes/Tokyo Night/wallpapers/"
    
    log "Copying Hyprland configuration files..."
    cp hyde-custom/.config/hypr/keybindings.conf .config/hypr/
    cp hyde-custom/.config/hypr/themes/theme.conf .config/hypr/themes/
    cp hyde-custom/.config/hypr/userprefs.conf .config/hypr/
    cp hyde-custom/.config/hypr/windowrules.conf .config/hypr/
    
    log "Copying Hyprland variables..."
    cp hyde-custom/.local/share/hypr/variables.conf .local/share/hypr/
    
    log "Copying Waybar configuration..."
    cp hyde-custom/.local/share/waybar/layouts/hellia.jsonc .local/share/waybar/layouts/
    cp hyde-custom/.local/share/waybar/modules/* .local/share/waybar/modules/
    
    log "Copying HyDE state configuration..."
    cp hyde-custom/.local/state/hyde/config .local/state/hyde/
    
    # Copy system configuration (requires sudo)
    log "Copying system configuration (ly config)..."
    if [[ -f "hyde-custom/etc/ly/config.ini" ]]; then
        sudo cp hyde-custom/etc/ly/config.ini /etc/ly/
        log "ly configuration copied successfully"
    else
        warn "ly configuration file not found, skipping..."
    fi
    
    log "=== Phase 2 Complete ==="
    log "Custom HyDE configuration has been applied successfully!"
    log "You may want to restart your session to ensure all changes take effect."
}

# Show usage information
usage() {
    echo "Usage: $0 [--phase1|--phase2|--help]"
    echo
    echo "Options:"
    echo "  --phase1    Run phase 1: Clone repos and install HyDE"
    echo "  --phase2    Run phase 2: Apply custom configuration"
    echo "  --help      Show this help message"
    echo
    echo "If no option is provided, phase 1 will be executed."
}

# Main execution
main() {
    case "${1:-}" in
        --phase1)
            phase1
            ;;
        --phase2)
            phase2
            ;;
        --help)
            usage
            ;;
        "")
            phase1
            ;;
        *)
            error "Unknown option: $1"
            usage
            ;;
    esac
}

# Trap to handle script interruption
trap 'error "Script interrupted by user"' INT

# Run main function with all arguments
main "$@"
