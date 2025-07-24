#!/bin/bash

set -euo pipefail

# Configuration
readonly REPO_URL="https://github.com/hellia-be/dotfiles.git"
readonly REPO_DIR="$HOME/Documents/git/dotfiles"
readonly HYPR_HOME="$HOME/.config/hypr/"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists yay; then
        missing_deps+=("yay")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Clone or update dotfiles repository
setup_dotfiles_repo() {
    if [ ! -d "$REPO_DIR" ]; then
        log_info "Cloning dotfiles repository..."
        if git clone "$REPO_URL" "$REPO_DIR"; then
            log_success "Repository cloned successfully"
        else
            log_error "Failed to clone repository. Check the URL and your internet connection."
            exit 1
        fi
    else
        log_info "Dotfiles repository already exists. Updating..."
        if (cd "$REPO_DIR" && git pull origin main); then
            log_success "Repository updated successfully"
        else
            log_warning "Failed to update repository. Continuing with existing version."
        fi
    fi
}

# Setup ML4W Hyprland
setup_ml4w_hyprland() {
    if ! command_exists ml4w-hyprland-setup; then
        log_info "ml4w-hyprland is not installed. Installing..."
        if yay -S --noconfirm ml4w-hyprland; then
            log_success "ml4w-hyprland installed successfully"
        else
            log_error "Failed to install ml4w-hyprland"
            exit 1
        fi
    fi
    
    if [ ! -f "$HOME/.config/ml4w/settings/browser.sh" ]; then
        log_info "Running ml4w-hyprland-setup for the first time..."
        if ml4w-hyprland-setup; then
            log_success "ml4w-hyprland-setup completed"
        else
            log_error "ml4w-hyprland-setup failed"
            exit 1
        fi
    else
        log_info "Updating ml4w-hyprland setup..."
        if ml4w-hyprland-setup -m update; then
            log_success "ml4w-hyprland-setup updated"
        else
            log_warning "ml4w-hyprland-setup update failed, continuing..."
        fi
    fi
}

# Install packages
install_packages() {
    local packages=(
        "z"
        "bat"
        "eza"
        "vim"
        "fzf"
        "fd"
        "thefuck"
        "zoxide"
        "dig"
        "hyprpolkitagent"
        "google-chrome"
        "megasync-bin"
        "obsidian"
        "spicetify-cli"
        "pywal-spicetify"
        "spotify-launcher"
        "discord"
        "ttf-3270-nerd"
        "steam"
        "protonup-qt"
        "adwaita-cursors"
        "adwaita-fonts"
        "adwaita-icon-theme"
        "adwaita-icon-theme-legacy"
        "bash-completion"
        "bibata-cursor-theme-bin"
        "blueman"
        "bluez"
        "bluez-libs"
        "bluez-utils"
        "breeze"
        "breeze-icons"
        "brightnessctl"
        "code"
        "darktable"
        "downgrade"
        "fastfetch"
        "gimp"
        "grim"
        "gvfs-smb"
        "linux-zen"
        "linux-zen-headers"
        "nordvpn-bin"
        "nordvpn-gui"
        "papirus-icon-theme"
        "pavucontrol"
        "playerctl"
        "reflector-simple"
        "unzip"
        "unrar"
        "vim"
        "vlc"
        "xz"
        "zip"
    )
    
    local failed_packages=()
    
    log_info "Installing packages..."
    for package in "${packages[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            log_info "$package is already installed"
        else
            log_info "Installing $package..."
            if yay -S --noconfirm "$package"; then
                log_success "$package installed successfully"
            else
                log_error "Failed to install $package"
                failed_packages+=("$package")
            fi
        fi
    done
    
    if [ ${#failed_packages[@]} -ne 0 ]; then
        log_warning "Failed to install packages: ${failed_packages[*]}"
        log_warning "You may need to install these manually later"
    else
        log_success "All packages installed successfully"
    fi
}

# Remove packages
remove_packages() {
    local packages_to_remove=(
        "firefox"
        "neovim"
    )
    
    local failed_removals=()
    
    log_info "Removing unwanted packages..."
    for package in "${packages_to_remove[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            log_info "Removing $package..."
            if yay -Rns --noconfirm "$package"; then
                log_success "$package removed successfully"
            else
                log_error "Failed to remove $package"
                failed_removals+=("$package")
            fi
        else
            log_info "$package is not installed"
        fi
    done
    
    if [ ${#failed_removals[@]} -ne 0 ]; then
        log_warning "Failed to remove packages: ${failed_removals[*]}"
    else
        log_success "Package removal completed"
    fi
}

# Create necessary directories
create_directories() {
    local directories=(
        "$HOME/Documents/git/fzf-git.sh"
        "$HOME/.config/hypr/scripts"
        "$HOME/.config/hypr/conf/keybindings"
        "$HOME/.config/hypr/conf/windowrules"
        "$HOME/.config/hypr/conf/decorations"
        "$HOME/.config/ml4w/settings/sddm"
        "$HOME/.config/waybar/themes/ml4w-modern"
        "$HOME/.config/hypr/conf/monitors"
    )
    
    log_info "Creating directories..."
    for dir in "${directories[@]}"; do
        if mkdir -p "$dir"; then
            log_info "Created directory: $dir"
        else
            log_error "Failed to create directory: $dir"
            exit 1
        fi
    done
    log_success "Directory creation completed"
}

# Create symbolic links
create_symlinks() {
    # Define symlinks as source:target pairs
    local -A symlinks=(
        ["$REPO_DIR/.bashrc_custom"]="$HOME/.bashrc_custom"
        ["$REPO_DIR/.config/hypr/scripts/screenshot.sh"]="$HYPR_HOME/scripts/screenshot.sh"
        ["$REPO_DIR/.config/hypr/scripts/resume-lock.sh"]="$HYPR_HOME/scripts/resume-lock.sh"
        ["$REPO_DIR/.config/hypr/conf/autostart.conf"]="$HYPR_HOME/conf/autostart.conf"
        ["$REPO_DIR/.config/hypr/conf/cursor.conf"]="$HYPR_HOME/conf/cursor.conf"
        ["$REPO_DIR/.config/hypr/conf/keyboard.conf"]="$HYPR_HOME/conf/keyboard.conf"
        ["$REPO_DIR/.config/hypr/colors.conf"]="$HYPR_HOME/colors.conf"
        ["$REPO_DIR/.config/hypr/conf/animation.conf"]="$HYPR_HOME/conf/animation.conf"
        ["$REPO_DIR/.config/hypr/conf/custom.conf"]="$HYPR_HOME/conf/custom.conf"
        ["$REPO_DIR/.config/hypr/conf/decoration.conf"]="$HYPR_HOME/conf/decoration.conf"
        ["$REPO_DIR/.config/hypr/conf/keybindings.conf"]="$HYPR_HOME/conf/keybindings.conf"
        ["$REPO_DIR/.config/hypr/conf/layout.conf"]="$HYPR_HOME/conf/layout.conf"
        ["$REPO_DIR/.config/hypr/conf/misc.conf"]="$HYPR_HOME/conf/misc.conf"
        ["$REPO_DIR/.config/hypr/conf/ml4w.conf"]="$HYPR_HOME/conf/ml4w.conf"
        ["$REPO_DIR/.config/hypr/conf/restorevariations.sh"]="$HYPR_HOME/conf/restorevariations.sh"
        ["$REPO_DIR/.config/hypr/conf/window.conf"]="$HYPR_HOME/conf/window.conf"
        ["$REPO_DIR/.config/hypr/conf/windowrule.conf"]="$HYPR_HOME/conf/windowrule.conf"
        ["$REPO_DIR/.config/hypr/conf/workspace.conf"]="$HYPR_HOME/conf/workspace.conf"
        ["$REPO_DIR/.config/hypr/conf/decorations/rounding-all-blur.conf"]="$HYPR_HOME/conf/decorations/rounding-all-blur.conf"
        ["$REPO_DIR/.config/hypr/conf/windowrules/default.conf"]="$HYPR_HOME/conf/windowrules/default.conf"
        ["$REPO_DIR/.config/hypr/conf/keybindings/default.conf"]="$HYPR_HOME/conf/keybindings/default.conf"
        ["$REPO_DIR/.config/hypr/conf/monitors/default.conf"]="$HYPR_HOME/conf/monitors/default.conf"
        ["$REPO_DIR/.config/waybar/modules.json"]="$HOME/.config/waybar/modules.json"
        ["$REPO_DIR/.config/waybar/themes/ml4w-modern/config"]="$HOME/.config/waybar/themes/ml4w-modern/config"
        ["$REPO_DIR/.config/waybar/themes/ml4w-modern/style.css"]="$HOME/.config/waybar/themes/ml4w-modern/style.css"
        ["$REPO_DIR/.config/ml4w/settings/browser.sh"]="$HOME/.config/ml4w/settings/browser.sh"
        ["$REPO_DIR/.config/ml4w/settings/rofi-font.rasi"]="$HOME/.config/ml4w/settings/rofi-font.rasi"
        ["$REPO_DIR/.config/ml4w/settings/screenshot-folder.sh"]="$HOME/.config/ml4w/settings/screenshot-folder.sh"
        ["$REPO_DIR/.config/ml4w/settings/sddm/theme.tpl"]="$HOME/.config/ml4w/settings/sddm/theme.tpl"
    )
    
    local failed_symlinks=()
    
    log_info "Creating symbolic links..."
    for source in "${!symlinks[@]}"; do
        local target="${symlinks[$source]}"
        
        if [ ! -e "$source" ]; then
            log_warning "Source file does not exist: $source"
            failed_symlinks+=("$source -> $target")
            continue
        fi
        
        # Remove existing file/symlink if it exists
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -f "$target"
        fi
        
        # Create parent directory if it doesn't exist
        mkdir -p "$(dirname "$target")"
        
        if ln -s "$source" "$target"; then
            log_info "Created symlink: $target -> $source"
        else
            log_error "Failed to create symlink: $target -> $source"
            failed_symlinks+=("$source -> $target")
        fi
    done
    
    if [ ${#failed_symlinks[@]} -ne 0 ]; then
        log_warning "Failed to create some symlinks:"
        printf '%s\n' "${failed_symlinks[@]}"
    else
        log_success "All symlinks created successfully"
    fi
}

# Main execution
main() {
    log_info "Starting dotfiles setup script..."
    
    check_dependencies
    setup_dotfiles_repo
    setup_ml4w_hyprland
    install_packages
    remove_packages
    create_directories
    create_symlinks
    
    log_success "Dotfiles setup completed successfully!"
    log_info "You may need to restart your session for all changes to take effect."
}

# Run main function
main "$@"
