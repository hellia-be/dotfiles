#!/bin/bash

set -euo pipefail

# Configuration
readonly REPO_URL="https://github.com/hellia-be/dotfiles.git"
readonly REPO_DIR="$HOME/Documents/git/dotfiles"
readonly HYPR_HOME="$HOME/.config/hypr/"
readonly WAYBAR_HOME="$HOME/.config/waybar"
readonly ROFI_HOME="$HOME/.config/rofi"
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers"

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

<<<<<<< HEAD
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

# Check if package is installed
_isInstalled() {
    package="$1"
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0
        return #true
    fi
    echo 1
    return #false
}

# Install yay if needed
_installYay() {
    if [[ ! $(_isInstalled "base-devel") == 0 ]]; then
        sudo pacman --noconfirm -S "base-devel"
    fi
    if [[ ! $(_isInstalled "git") == 0 ]]; then
        sudo pacman --noconfirm -S "git"
    fi
    if [ -d $HOME/Downloads/yay-bin ]; then
        rm -rf $HOME/Downloads/yay-bin
    fi
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay-bin.git $HOME/Downloads/yay-bin
    cd $HOME/Downloads/yay-bin
    makepkg -si
    cd $temp_path
    log_success "yay has been installed successfully."
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()

    local required_deps=(
        "git"
        "yay"
        "hyprland"
        "curl"
        "wget"
        "unzip"
    )

    for dep in "${required_deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
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
=======
# Array of packages to check and install
packages=(
	"z"
	"bat"
	"eza"
	"vim"
	"fzf"
	"fd"
	"thefuck"
	"zoxide"
	"bind"
	"hyprpolkitagent"
	"google-chrome"
	"megasync-bin"
	"obsidian"
	"spicetify-cli"
	"pywal-spicetify"
	"discord"
	"spotify-launcher"
	"steam"
 	"darktable"
  	"gimp"
   	"nordvpn-bin"
    	"nordvpn-gui"
     	"protonup-qt"
      	"vlc"
)
>>>>>>> 786c8a0e1806f02fcc378555691152270bae5375

# Install packages
install_packages() {
    # Core Hyprland ecosystem - updated based on ML4W and your current system
    local hyprland_packages=(
        "hyprland"
        "hyprpaper"
        "hyprlock"
        "hypridle"
        "hyprpicker"
        "hyprshade"
        "xdg-desktop-portal-hyprland"
        "libnotify"
        "qt5-wayland"
        "qt6-wayland"
        "fastfetch"
        "xdg-desktop-portal-gtk"
    )

    # Wayland utilities - enhanced from ML4W
    local wayland_packages=(
        "waybar"
        "rofi-wayland"
        "swaync"          # Better notification daemon than dunst
        "wlogout"
        "swww"
        "waypaper"        # Better wallpaper manager
        "grim"
        "slurp"
        "grimblast-git"   # Enhanced screenshot tool
        "wl-clipboard"
        "cliphist"        # Clipboard manager
        "nwg-look"        # GTK theme manager
        "qt6ct"           # Qt theme manager
        "nwg-dock-hyprland"
    )

    # System utilities
    local system_packages=(
        "polkit-gnome"    # Keep your current polkit implementation
        "brightnessctl"
        "pavucontrol"
        "power-profiles-daemon"
        "uwsm"            # Session manager
        "playerctl"
        "network-manager-applet"
        "nm-connection-editor"
        "blueman"
        "flatpak"
        "gvfs"
        "gvfs-smb"
    )

    # Theme and appearance - enhanced
    local theme_packages=(
        "imagemagick"
        "jq"
        "bibata-cursor-theme-bin"
        "papirus-icon-theme"
        "breeze"
        "breeze-icons"
        "adwaita-cursors"
        "adwaita-fonts"
        "adwaita-icon-theme"
        "adwaita-icon-theme-legacy"
    )

    # Audio and media - using pipewire (already installed)
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "pipewire-jack"
        "wireplumber"
        "pavucontrol"
        "playerctl"
    )

<<<<<<< HEAD
    # Fonts - enhanced from ML4W
    local font_packages=(
        "noto-fonts"
        "noto-fonts-emoji"
        "noto-fonts-cjk"
        "noto-fonts-extra"
        "ttf-fira-sans"
        "ttf-fira-code"
        "ttf-firacode-nerd"
        "ttf-dejavu"
        "otf-font-awesome"
    )

    # Essential tools - keeping your selections
    local core_packages=(
        "zsh"
        "fzf"
        "z"
        "bat"
        "eza"
        "vim"
        "neovim"          # Adding back as it's useful
        "fd"
        "thefuck"
        "zoxide"
        "dig"
        "htop"
        "kitty"
        "nautilus"
        "python-pip"
        "python-gobject"
        "python-screeninfo"
        "tumbler"
        "loupe"           # Image viewer
        "checkupdates-with-aur"
        "pacseek"
    )

    # Applications - keeping your selections plus ML4W additions
    local app_packages=(
        "google-chrome"
        "megasync-bin"
        "obsidian"
        "discord"
        "code"
        "gimp"
        "vlc"
        "darktable"
        "steam"
        "protonup-qt"
        "spotify-launcher"
        "spicetify-cli"
        "pywal-spicetify"
    )

    # System utilities - enhanced
    local util_packages=(
        "bash-completion"
        "downgrade"
        "reflector-simple"
        "unzip"
        "unrar"
        "xz"
        "zip"
        "bluez"
        "bluez-libs"
        "bluez-utils"
        "nordvpn-bin"
        "nordvpn-gui"
        "linux-zen"
        "linux-zen-headers"
    )

    # Combine all packages
    local all_packages=(
        "${hyprland_packages[@]}"
        "${wayland_packages[@]}"
        "${system_packages[@]}"
        "${theme_packages[@]}"
        "${audio_packages[@]}"
        "${font_packages[@]}"
        "${core_packages[@]}"
        "${app_packages[@]}"
        "${util_packages[@]}"
    )

    local failed_packages=()
    
    log_info "Installing packages..."
    for package in "${all_packages[@]}"; do
        if [[ $(_isInstalled "${package}") == 0 ]]; then
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

# Remove conflicting packages
remove_packages() {
    local packages_to_remove=(
        "firefox"           # You prefer Chrome
        "ml4w-hyprland"     # We're creating our own setup
        "dunst"             # Using swaync instead
    )
    
    local failed_removals=()
    
    log_info "Removing conflicting packages..."
    for package in "${packages_to_remove[@]}"; do
        if [[ $(_isInstalled "${package}") == 0 ]]; then
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

# Install Oh My Posh
install_oh_my_posh() {
    if ! command_exists "oh-my-posh"; then
        log_info "Installing Oh My Posh..."
        curl -s https://ohmyposh.dev/install.sh | bash -s
        log_success "Oh My Posh installed successfully"
    else
        log_info "Oh My Posh is already installed"
    fi
}

# Install additional tools
install_additional_tools() {
    # Create local bin directory
    if [ ! -d $HOME/.local/bin ]; then
        mkdir -p $HOME/.local/bin
    fi

    # Note: You would need to add these binaries to your repo or download them
    # For now, just creating the directory structure
    log_info "Additional tools directory created at ~/.local/bin"
    
    # Install Flatpak applications
    log_info "Installing Flatpak applications..."
    if command_exists "flatpak"; then
        flatpak install -y flathub com.github.PintaProject.Pinta 2>/dev/null || log_warning "Failed to install Pinta via Flatpak"
    fi
}

# Create necessary directories
create_directories() {
    local directories=(
        "$HYPR_HOME/conf"
        "$HYPR_HOME/scripts"
        "$HYPR_HOME/conf/keybindings"
        "$HYPR_HOME/conf/windowrules"
        "$HYPR_HOME/conf/decorations"
        "$HYPR_HOME/conf/monitors"
        "$WAYBAR_HOME/themes/custom"
        "$WAYBAR_HOME/themes/ml4w-modern"
        "$ROFI_HOME"
        "$HOME/.config/swaync"
        "$HOME/.config/swww"
        "$HOME/.config/ml4w/settings"
        "$HOME/.config/ml4w/settings/sddm"
        "$HOME/.local/share/applications"
        "$HOME/.local/bin"
        "$WALLPAPER_DIR"
        "$HOME/Documents/git/fzf-git.sh"
        "$HOME/Pictures/screenshots"
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
        # Bash configuration
        ["$REPO_DIR/.bashrc_custom"]="$HOME/.bashrc_custom"
        
        # Hyprland scripts
        ["$REPO_DIR/.config/hypr/scripts/screenshot.sh"]="$HYPR_HOME/scripts/screenshot.sh"
        ["$REPO_DIR/.config/hypr/scripts/resume-lock.sh"]="$HYPR_HOME/scripts/resume-lock.sh"
        ["$REPO_DIR/.config/hypr/scripts/power.sh"]="$HYPR_HOME/scripts/power.sh"
        ["$REPO_DIR/.config/hypr/scripts/wallpaper.sh"]="$HYPR_HOME/scripts/wallpaper.sh"
        ["$REPO_DIR/.config/hypr/conf/restorevariations.sh"]="$HYPR_HOME/conf/restorevariations.sh"
        
        # Hyprland configuration files
        ["$REPO_DIR/.config/hypr/hyprland.conf"]="$HYPR_HOME/hyprland.conf"
        ["$REPO_DIR/.config/hypr/colors.conf"]="$HYPR_HOME/colors.conf"
        ["$REPO_DIR/.config/hypr/conf/autostart.conf"]="$HYPR_HOME/conf/autostart.conf"
        ["$REPO_DIR/.config/hypr/conf/cursor.conf"]="$HYPR_HOME/conf/cursor.conf"
        ["$REPO_DIR/.config/hypr/conf/keyboard.conf"]="$HYPR_HOME/conf/keyboard.conf"
        ["$REPO_DIR/.config/hypr/conf/animation.conf"]="$HYPR_HOME/conf/animation.conf"
        ["$REPO_DIR/.config/hypr/conf/custom.conf"]="$HYPR_HOME/conf/custom.conf"
        ["$REPO_DIR/.config/hypr/conf/decoration.conf"]="$HYPR_HOME/conf/decoration.conf"
        ["$REPO_DIR/.config/hypr/conf/keybindings.conf"]="$HYPR_HOME/conf/keybindings.conf"
        ["$REPO_DIR/.config/hypr/conf/layout.conf"]="$HYPR_HOME/conf/layout.conf"
        ["$REPO_DIR/.config/hypr/conf/misc.conf"]="$HYPR_HOME/conf/misc.conf"
        ["$REPO_DIR/.config/hypr/conf/ml4w.conf"]="$HYPR_HOME/conf/ml4w.conf"
        ["$REPO_DIR/.config/hypr/conf/window.conf"]="$HYPR_HOME/conf/window.conf"
        ["$REPO_DIR/.config/hypr/conf/windowrule.conf"]="$HYPR_HOME/conf/windowrule.conf"
        ["$REPO_DIR/.config/hypr/conf/workspace.conf"]="$HYPR_HOME/conf/workspace.conf"
        
        # Hyprland sub-configurations
        ["$REPO_DIR/.config/hypr/conf/decorations/rounding-all-blur.conf"]="$HYPR_HOME/conf/decorations/rounding-all-blur.conf"
        ["$REPO_DIR/.config/hypr/conf/windowrules/default.conf"]="$HYPR_HOME/conf/windowrules/default.conf"
        ["$REPO_DIR/.config/hypr/conf/keybindings/default.conf"]="$HYPR_HOME/conf/keybindings/default.conf"
        ["$REPO_DIR/.config/hypr/conf/monitors/default.conf"]="$HYPR_HOME/conf/monitors/default.conf"
        
        # Waybar configuration
        ["$REPO_DIR/.config/waybar/modules.json"]="$WAYBAR_HOME/modules.json"
        ["$REPO_DIR/.config/waybar/launch.sh"]="$WAYBAR_HOME/launch.sh"
        ["$REPO_DIR/.config/waybar/themes/ml4w-modern/config"]="$WAYBAR_HOME/themes/ml4w-modern/config"
        ["$REPO_DIR/.config/waybar/themes/ml4w-modern/style.css"]="$WAYBAR_HOME/themes/ml4w-modern/style.css"
        
        # Rofi configuration
        ["$REPO_DIR/.config/rofi/colors.rasi"]="$ROFI_HOME/colors.rasi"
        ["$REPO_DIR/.config/rofi/config-compact.rasi"]="$ROFI_HOME/config-compact.rasi"
        ["$REPO_DIR/.config/rofi/config-hyprshade.rasi"]="$ROFI_HOME/config-hyprshade.rasi"
        ["$REPO_DIR/.config/rofi/config-screenshot.rasi"]="$ROFI_HOME/config-screenshot.rasi"
        ["$REPO_DIR/.config/rofi/config-short.rasi"]="$ROFI_HOME/config-short.rasi"
        ["$REPO_DIR/.config/rofi/config-themes.rasi"]="$ROFI_HOME/config-themes.rasi"
        ["$REPO_DIR/.config/rofi/config.rasi"]="$ROFI_HOME/config.rasi"
        
        # SWAYNC configuration
        ["$REPO_DIR/.config/swaync/colors.css"]="$HOME/.config/swaync/colors.css"
        ["$REPO_DIR/.config/swaync/config.json"]="$HOME/.config/swaync/config.json"
        ["$REPO_DIR/.config/swaync/style.css"]="$HOME/.config/swaync/style.css"
        
        # ML4W settings
        ["$REPO_DIR/.config/ml4w/settings/browser.sh"]="$HOME/.config/ml4w/settings/browser.sh"
        ["$REPO_DIR/.config/ml4w/settings/rofi-font.rasi"]="$HOME/.config/ml4w/settings/rofi-font.rasi"
        ["$REPO_DIR/.config/ml4w/settings/screenshot-folder.sh"]="$HOME/.config/ml4w/settings/screenshot-folder.sh"
        ["$REPO_DIR/.config/ml4w/settings/sddm/theme.tpl"]="$HOME/.config/ml4w/settings/sddm/theme.tpl"
        
        # Kitty configuration
        ["$REPO_DIR/.config/kitty/colors-mutagen.conf"]="$HOME/.config/kitty/colors-mutagen.conf"
        ["$REPO_DIR/.config/kitty/colors-wallust.conf"]="$HOME/.config/kitty/colors-wallust.conf"
        ["$REPO_DIR/.config/kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
        
        # Additional configuration files you might want to symlink
        # ["$REPO_DIR/.zshrc"]="$HOME/.zshrc"
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

    # Make scripts executable
    if [ -d "$HYPR_HOME/scripts" ]; then
        chmod +x "$HYPR_HOME/scripts/"*.sh 2>/dev/null || true
    fi
    if [ -d "$WAYBAR_HOME" ]; then
        chmod +x "$WAYBAR_HOME/"*.sh 2>/dev/null || true
    fi
}

# Enable systemd services
enable_services() {
    local services=(
        "bluetooth.service"
        "power-profiles-daemon.service"
    )
    
    log_info "Enabling systemd services..."
    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" >/dev/null 2>&1; then
            log_info "$service is already enabled"
        else
            if sudo systemctl enable "$service"; then
                log_success "Enabled $service"
            else
                log_warning "Failed to enable $service"
            fi
        fi
    done
}

# Print final instructions
print_instructions() {
    log_success "Dotfiles setup completed successfully!"
    echo
    log_info "Next steps:"
    echo "  1. Restart your session or reboot for all changes to take effect"
    echo "  2. Configure your monitors in ~/.config/hypr/conf/monitors/default.conf"
    echo "  3. Set up your wallpapers in $WALLPAPER_DIR"
    echo "  4. Customize keybindings in ~/.config/hypr/conf/keybindings/default.conf"
    echo "  5. If using SDDM, configure the theme"
    echo
    log_info "Useful commands:"
    echo "  - hyprctl reload: Reload Hyprland configuration"
    echo "  - waybar: Restart waybar"
    echo "  - swaync-client -t: Toggle notification center"
    echo
}

# Main execution
main() {
    log_info "Starting enhanced dotfiles setup script..."
    
    # Header similar to ML4W
    echo -e "${GREEN}"
    cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF
    echo "Enhanced Dotfiles Setup for Hyprland"
    echo -e "${NC}"
    
    while true; do
        read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
        case $yn in
            [Yy]*)
                echo ":: Installation started."
                echo
                break
                ;;
            [Nn]*)
                echo ":: Installation canceled"
                exit
                break
                ;;
            *)
                echo ":: Please answer yes or no."
                ;;
        esac
    done
    
    # Install yay if needed
    if ! command_exists "yay"; then
        log_info "The installer requires yay. yay will be installed now"
        _installYay
    else
        log_info "yay is already installed"
    fi
    
    check_dependencies
    setup_dotfiles_repo
    install_packages
    remove_packages
    install_oh_my_posh
    install_additional_tools
    create_directories
    create_symlinks
    enable_services
    print_instructions
}

# Run main function
main "$@"
=======
# Creating directories (using -p for parent directories)
echo "Creating directories..."
mkdir -p "$HOME/Documents/git/fzf-git.sh"
mkdir -p "$HOME/.config/hypr/scripts"
mkdir -p "$HOME/.config/hypr/conf/keybindings"
mkdir -p "$HOME/.config/hypr/conf/windowrules"
mkdir -p "$HOME/.config/ml4w/settings/sddm"
mkdir -p "$HOME/.config/waybar/themes/ml4w-modern"
mkdir -p "$HOME/.config/hypr/conf/monitors"
echo "Finished creating directories."

# Setting links
echo "Creating symbolic links..."
ln -sf "$HOME/Documents/git/dotfiles/.bashrc_custom" "$HOME/"
ln -sf "$HOME/Documents/git/dotfiles/git/fzf-git.sh/fzf-git.sh" "$HOME/Documents/git/fzf-git.sh/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/scripts/screenshot.sh" "$HOME/.config/hypr/scripts/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/scripts/resume-lock.sh" "$HOME/.config/hypr/scripts/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/autostart.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/cursor.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/keybindings/default.conf" "$HOME/.config/hypr/conf/keybindings/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/keyboard.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/windowrules/default.conf" "$HOME/.config/hypr/conf/windowrules/"
ln -sf "$HOME/Documents/git/dotfiles/.config/ml4w/settings/browser.sh" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/Documents/git/dotfiles/.config/ml4w/settings/rofi-font.rasi" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/Documents/git/dotfiles/.config/ml4w/settings/screenshot-folder.sh" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/Documents/git/dotfiles/.config/ml4w/settings/sddm/theme.tpl" "$HOME/.config/ml4w/settings/sddm/"
ln -sf "$HOME/Documents/git/dotfiles/.config/waybar/modules.json" "$HOME/.config/waybar/"
ln -sf "$HOME/Documents/git/dotfiles/.config/waybar/themes/ml4w-modern/config" "$HOME/.config/waybar/themes/ml4w-modern/"
ln -sf "$HOME/Documents/git/dotfiles/.config/waybar/themes/ml4w-modern/style.css" "$HOME/.config/waybar/themes/ml4w-modern/"
ln -sf "$HOME/Documents/git/dotfiles/.config/hypr/conf/monitors/default.conf" "$HOME/.config/hypr/conf/monitors/"
echo "Finished creating symbolic links."
echo "Script completed."
>>>>>>> 786c8a0e1806f02fcc378555691152270bae5375
