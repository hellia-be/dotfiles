#!/bin/bash

# HyDE Custom Setup Installer
# Author: Custom HyDE Configuration
# Description: Installs custom HyDE configurations after base HyDE installation
# Version: 1.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_NAME="hyde-custom"
BACKUP_DIR="$HOME/.hyde-custom-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/hyde-custom-install.log"

# Functions
print_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    HyDE Custom Installer                     ║
║                                                               ║
║              Custom configurations for HyDE                  ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            echo -e "${CYAN}[DEBUG]${NC} $message"
            ;;
    esac
}

check_dependencies() {
    log_message "INFO" "Checking dependencies..."
    
    local missing_deps=()
    local required_commands=("git" "rsync" "curl")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_message "ERROR" "Missing dependencies: ${missing_deps[*]}"
        log_message "INFO" "Installing missing dependencies..."
        
        if command -v pacman &> /dev/null; then
            sudo pacman -S --needed --noconfirm "${missing_deps[@]}"
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "${missing_deps[@]}"
        else
            log_message "ERROR" "Unable to install dependencies. Please install manually: ${missing_deps[*]}"
            exit 1
        fi
    fi
    
    log_message "INFO" "All dependencies satisfied"
}

check_hyde_installation() {
    log_message "INFO" "Checking HyDE installation..."
    
    if [ ! -d "$HOME/.config/hyde" ]; then
        log_message "ERROR" "HyDE not found! Please install HyDE first."
        echo
        echo -e "${YELLOW}To install HyDE with your custom package list:${NC}"
        echo -e "1. Clone your repo: ${CYAN}git clone [YOUR_REPO_URL] ~/hyde-custom${NC}"
        echo -e "2. Copy pkg list: ${CYAN}cp ~/hyde-custom/HyDE/Scripts/pkg_user.lst ~/Downloads/${NC}"
        echo -e "3. Install HyDE: ${CYAN}curl -sL https://raw.githubusercontent.com/HyDE-Project/HyDE/main/Scripts/install.sh | bash${NC}"
        echo -e "4. Then run this installer again"
        exit 1
    fi
    
    if [ ! -d "$HOME/.config/hypr" ]; then
        log_message "ERROR" "Hyprland configuration not found! HyDE installation may be incomplete."
        exit 1
    fi
    
    log_message "INFO" "HyDE installation verified"
}

create_backup() {
    log_message "INFO" "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing configurations
    local backup_paths=(
        "$HOME/.config/hyde"
        "$HOME/.config/hypr"
        "$HOME/.local/share/waybar"
        "$HOME/.local/state/hyde"
    )
    
    for path in "${backup_paths[@]}"; do
        if [ -e "$path" ]; then
            local dest="$BACKUP_DIR/$(basename "$path")"
            cp -r "$path" "$dest" 2>/dev/null || true
            log_message "INFO" "Backed up: $path -> $dest"
        fi
    done
    
    log_message "INFO" "Backup completed"
}

get_repo_url() {
    echo -e "${BLUE}Please provide your repository URL:${NC}"
    echo -e "${CYAN}Examples:${NC}"
    echo "  - https://github.com/username/repo-name"
    echo "  - git@github.com:username/repo-name.git"
    echo "  - https://gitlab.com/username/repo-name"
    echo
    read -p "Repository URL: " repo_url
    
    if [[ -z "$repo_url" ]]; then
        log_message "ERROR" "Repository URL cannot be empty"
        exit 1
    fi
    
    echo "$repo_url"
}

clone_and_setup_repository() {
    local repo_url=$1
    local clone_dir="$HOME/.hyde-custom-config"
    
    if [ -d "$clone_dir" ]; then
        log_message "INFO" "Found existing repository at $clone_dir"
        echo -e "${YELLOW}Repository already exists. What would you like to do?${NC}"
        echo "1) Update existing repository (git pull)"
        echo "2) Remove and re-clone"
        echo "3) Use existing as-is"
        read -p "Choose option [1-3]: " choice
        
        case $choice in
            1)
                log_message "INFO" "Updating existing repository..."
                cd "$clone_dir"
                if git pull; then
                    log_message "INFO" "Repository updated successfully"
                else
                    log_message "ERROR" "Failed to update repository"
                    exit 1
                fi
                ;;
            2)
                log_message "INFO" "Removing existing repository..."
                rm -rf "$clone_dir"
                if git clone "$repo_url" "$clone_dir"; then
                    log_message "INFO" "Repository cloned successfully"
                else
                    log_message "ERROR" "Failed to clone repository"
                    exit 1
                fi
                ;;
            3)
                log_message "INFO" "Using existing repository"
                ;;
            *)
                log_message "ERROR" "Invalid choice"
                exit 1
                ;;
        esac
    else
        log_message "INFO" "Cloning repository from $repo_url..."
        if git clone "$repo_url" "$clone_dir"; then
            log_message "INFO" "Repository cloned successfully"
        else
            log_message "ERROR" "Failed to clone repository"
            exit 1
        fi
    fi
    
    echo "$clone_dir"
}

create_symlinks() {
    local repo_dir=$1
    
    log_message "INFO" "Creating symlinks for custom configurations..."
    
    # Create necessary parent directories
    mkdir -p "$HOME/.config/hyde/themes"
    mkdir -p "$HOME/.config/hypr/themes"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/waybar/layouts"
    mkdir -p "$HOME/.local/share/waybar/modules"
    mkdir -p "$HOME/.local/state/hyde"
    mkdir -p "$HOME/.local/bin"
    
    # Symlink Tokyo Night theme
    if [ -d "$repo_dir/.config/hyde/themes/Tokyo Night" ]; then
        local target_theme="$HOME/.config/hyde/themes/Tokyo Night"
        if [ -e "$target_theme" ]; then
            log_message "INFO" "Removing existing Tokyo Night theme..."
            rm -rf "$target_theme"
        fi
        log_message "INFO" "Symlinking Tokyo Night theme..."
        ln -sf "$repo_dir/.config/hyde/themes/Tokyo Night" "$target_theme"
    fi
    
    # Symlink Hyprland configurations
    local hypr_files=("hyprland.conf" "keybindings.conf" "userprefs.conf")
    for file in "${hypr_files[@]}"; do
        if [ -f "$repo_dir/.config/hypr/$file" ]; then
            local target="$HOME/.config/hypr/$file"
            if [ -e "$target" ] || [ -L "$target" ]; then
                log_message "INFO" "Backing up existing $file..."
                mv "$target" "$target.backup-$(date +%s)" 2>/dev/null || true
            fi
            log_message "INFO" "Symlinking $file..."
            ln -sf "$repo_dir/.config/hypr/$file" "$target"
        fi
    done
    
    # Symlink theme.conf
    if [ -f "$repo_dir/.config/hypr/themes/theme.conf" ]; then
        local target="$HOME/.config/hypr/themes/theme.conf"
        if [ -e "$target" ] || [ -L "$target" ]; then
            log_message "INFO" "Backing up existing theme.conf..."
            mv "$target" "$target.backup-$(date +%s)" 2>/dev/null || true
        fi
        log_message "INFO" "Symlinking theme.conf..."
        ln -sf "$repo_dir/.config/hypr/themes/theme.conf" "$target"
    fi
    
    # Symlink applications
    if [ -f "$repo_dir/.local/share/applications/obsidian.desktop" ]; then
        local target="$HOME/.local/share/applications/obsidian.desktop"
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -f "$target"
        fi
        log_message "INFO" "Symlinking obsidian.desktop..."
        ln -sf "$repo_dir/.local/share/applications/obsidian.desktop" "$target"
    fi
    
    # Symlink waybar layouts
    if [ -f "$repo_dir/.local/share/waybar/layouts/hellia.jsonc" ]; then
        local target="$HOME/.local/share/waybar/layouts/hellia.jsonc"
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -f "$target"
        fi
        log_message "INFO" "Symlinking waybar layout hellia.jsonc..."
        ln -sf "$repo_dir/.local/share/waybar/layouts/hellia.jsonc" "$target"
    fi
    
    # Symlink waybar modules
    if [ -f "$repo_dir/.local/share/waybar/modules/clock.jsonc" ]; then
        local target="$HOME/.local/share/waybar/modules/clock.jsonc"
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -f "$target"
        fi
        log_message "INFO" "Symlinking waybar module clock.jsonc..."
        ln -sf "$repo_dir/.local/share/waybar/modules/clock.jsonc" "$target"
    fi
    
    # Symlink hyde state config
    if [ -f "$repo_dir/.local/state/hyde/config" ]; then
        local target="$HOME/.local/state/hyde/config"
        if [ -e "$target" ] || [ -L "$target" ]; then
            log_message "INFO" "Backing up existing hyde state config..."
            mv "$target" "$target.backup-$(date +%s)" 2>/dev/null || true
        fi
        log_message "INFO" "Symlinking hyde state config..."
        ln -sf "$repo_dir/.local/state/hyde/config" "$target"
    fi
    
    # Symlink custom scripts (if any)
    if [ -d "$repo_dir/git" ]; then
        log_message "INFO" "Symlinking custom scripts..."
        find "$repo_dir/git" -name "*.sh" -type f | while read -r script; do
            local script_name=$(basename "$script")
            local target="$HOME/.local/bin/$script_name"
            if [ -e "$target" ] || [ -L "$target" ]; then
                rm -f "$target"
            fi
            ln -sf "$script" "$target"
            chmod +x "$script"
        done
    fi
    
    # Copy pkg_user.lst (this needs to be copied, not symlinked, for HyDE installer)
    if [ -f "$repo_dir/HyDE/Scripts/pkg_user.lst" ]; then
        log_message "INFO" "Installing user package list..."
        cp "$repo_dir/HyDE/Scripts/pkg_user.lst" "$HOME/.config/hyde/"
    fi
    
    log_message "INFO" "Symlink creation completed"
}

set_permissions() {
    log_message "INFO" "Setting proper permissions..."
    
    # Set executable permissions for scripts
    find "$HOME/.local/bin" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$HOME/.config/hypr" -name "*.conf" -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    # Set permissions for waybar modules
    find "$HOME/.local/share/waybar" -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    log_message "INFO" "Permissions set successfully"
}

install_additional_packages() {
    log_message "INFO" "Checking for additional packages to install..."
    
    local pkg_file="$HOME/.config/hyde/pkg_user.lst"
    if [ -f "$pkg_file" ]; then
        log_message "INFO" "Found user package list, installing packages..."
        
        while IFS= read -r package; do
            # Skip empty lines and comments
            if [[ -n "$package" && ! "$package" =~ ^# ]]; then
                if command -v pacman &> /dev/null; then
                    if ! pacman -Qi "$package" &> /dev/null; then
                        log_message "INFO" "Installing package: $package"
                        sudo pacman -S --needed --noconfirm "$package" || log_message "WARN" "Failed to install: $package"
                    fi
                fi
            fi
        done < "$pkg_file"
    fi
}

reload_configurations() {
    log_message "INFO" "Reloading configurations..."
    
    # Reload Hyprland if running
    if pgrep -x "Hyprland" > /dev/null; then
        log_message "INFO" "Reloading Hyprland configuration..."
        hyprctl reload || log_message "WARN" "Failed to reload Hyprland"
    fi
    
    # Restart waybar if running
    if pgrep -x "waybar" > /dev/null; then
        log_message "INFO" "Restarting waybar..."
        pkill waybar || true
        sleep 2
        waybar &> /dev/null & disown || log_message "WARN" "Failed to restart waybar"
    fi
    
    log_message "INFO" "Configuration reload completed"
}

cleanup() {
    local repo_dir=$1
    
    log_message "INFO" "Repository will remain at: $repo_dir"
    log_message "INFO" "You can update your configs anytime with: cd $repo_dir && git pull"
}

show_completion_message() {
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  Installation Completed!                     ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Your custom HyDE setup has been installed successfully!${NC}"
    echo
    echo -e "${YELLOW}What was installed:${NC}"
    echo -e "  • Tokyo Night theme for HyDE (symlinked)"
    echo -e "  • Custom Hyprland configurations (symlinked)"
    echo -e "  • Custom waybar layouts and modules (symlinked)"
    echo -e "  • Additional applications and scripts (symlinked)"
    echo -e "  • User package list (copied)"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. ${CYAN}Log out and log back in${NC} (or restart your session)"
    echo -e "  2. ${CYAN}Open HyDE theme selector${NC} and select 'Tokyo Night'"
    echo -e "  3. ${CYAN}Apply the theme${NC} to see your customizations"
    echo
    echo -e "${YELLOW}Updates:${NC}"
    echo -e "  • Config repo: ${CYAN}$repo_dir${NC}"
    echo -e "  • Update configs: ${CYAN}cd $repo_dir && git pull${NC}"
    echo -e "  • Re-run installer: ${CYAN}$0${NC}"
    echo
    echo -e "${YELLOW}Backup location:${NC} $BACKUP_DIR"
    echo -e "${YELLOW}Installation log:${NC} $LOG_FILE"
    echo
    echo -e "${GREEN}Enjoy your customized HyDE setup! 🎉${NC}"
}

show_help() {
    cat << EOF
HyDE Custom Setup Installer

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -u, --url URL       Repository URL (skip interactive prompt)
    -b, --backup-dir    Custom backup directory
    --no-packages       Skip additional package installation
    --no-reload         Skip configuration reload
    --verbose           Enable verbose logging

EXAMPLES:
    $0                                          # Interactive installation
    $0 -u https://github.com/user/hyde-custom  # Direct URL installation
    $0 --no-packages --no-reload               # Minimal installation

REQUIREMENTS:
    - Arch Linux (or compatible)
    - HyDE already installed
    - Internet connection for cloning repository

EOF
}

main() {
    local repo_url=""
    local skip_packages=false
    local skip_reload=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--url)
                repo_url="$2"
                shift 2
                ;;
            -b|--backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            --no-packages)
                skip_packages=true
                shift
                ;;
            --no-reload)
                skip_reload=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                log_message "ERROR" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Initialize
    print_banner
    echo "Starting installation at $(date)" > "$LOG_FILE"
    
    # Pre-installation checks
    check_dependencies
    check_hyde_installation
    
    # Get repository URL if not provided
    if [[ -z "$repo_url" ]]; then
        repo_url=$(get_repo_url)
    fi
    
    # Create backup
    create_backup
    
    # Clone and install
    local repo_dir
    repo_dir=$(clone_and_setup_repository "$repo_url")
    
    create_symlinks "$repo_dir"
    set_permissions
    
    # Optional steps
    if [[ "$skip_packages" != "true" ]]; then
        install_additional_packages
    fi
    
    if [[ "$skip_reload" != "true" ]]; then
        reload_configurations
    fi
    
    # Cleanup and finish
    cleanup "$repo_dir"
    show_completion_message
    
    log_message "INFO" "Installation completed successfully"
}

# Trap to handle interruptions
trap 'log_message "ERROR" "Installation interrupted"; exit 1' INT TERM

# Run main function with all arguments
main "$@"
