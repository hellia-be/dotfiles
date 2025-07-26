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
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables for tracking
declare -a FAILED_PACKAGES=()
declare -a MISSING_PACKAGES=()
declare -a INSTALLED_PACKAGES=()

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

log_progress() {
    echo -e "${PURPLE}[PROGRESS]${NC} $1"
}

log_check() {
    echo -e "${CYAN}[CHECK]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Enhanced package check function
_isInstalled() {
    local package="$1"
    if pacman -Qi "$package" &>/dev/null; then
        echo 0
        return
    fi
    echo 1
    return
}

# Hardware detection
detect_hardware() {
    local gpu_info=""
    local has_nvidia=false
    local has_amd=false
    
    if command_exists "lspci"; then
        gpu_info=$(lspci | grep -i vga)
        
        if echo "$gpu_info" | grep -i nvidia &>/dev/null; then
            has_nvidia=true
            log_info "NVIDIA GPU detected"
        fi
        
        if echo "$gpu_info" | grep -i amd &>/dev/null || echo "$gpu_info" | grep -i radeon &>/dev/null; then
            has_amd=true
            log_info "AMD GPU detected"
        fi
    fi
    
    # Export for use in other functions
    export HAS_NVIDIA=$has_nvidia
    export HAS_AMD=$has_amd
}

# Install yay if needed
_installYay() {
    if [[ ! $(_isInstalled "base-devel") == 0 ]]; then
        sudo pacman --noconfirm -S "base-devel"
    fi
    if [[ ! $(_isInstalled "git") == 0 ]]; then
        sudo pacman --noconfirm -S "git"
    fi
    if [ -d "$HOME/Downloads/yay-bin" ]; then
        rm -rf "$HOME/Downloads/yay-bin"
    fi
    
    local script_path=$(realpath "$0")
    local temp_path=$(dirname "$script_path")
    
    git clone https://aur.archlinux.org/yay-bin.git "$HOME/Downloads/yay-bin"
    cd "$HOME/Downloads/yay-bin"
    makepkg -si --noconfirm
    cd "$temp_path"
    log_success "yay has been installed successfully."
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    local required_deps=(
        "git"
        "yay"
        "curl"
        "wget"
        "unzip"
    )

    log_progress "Checking dependencies..."
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
    
    log_success "All dependencies are available"
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

# Install single package with verification
install_single_package() {
    local package="$1"
    local category="${2:-general}"
    
    if [[ $(_isInstalled "${package}") == 0 ]]; then
        log_info "[$category] $package is already installed"
        INSTALLED_PACKAGES+=("$package")
        return 0
    else
        log_progress "[$category] Installing $package..."
        if yay -S --noconfirm --needed "$package" 2>/dev/null; then
            log_success "[$category] $package installed successfully"
            INSTALLED_PACKAGES+=("$package")
            return 0
        else
            log_error "[$category] Failed to install $package"
            FAILED_PACKAGES+=("$package")
            return 1
        fi
    fi
}

# Install packages with categorization and hardware detection
install_packages() {
    log_progress "Starting package installation..."
    
    # Core system packages
    local core_system=(
        "base-devel"
        "linux-zen"
        "linux-zen-headers"
        "linux-firmware"
        "linux-api-headers"
    )
    
    # Hyprland ecosystem
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
        "hyprcursor"
        "hyprutils"
        "hyprwayland-scanner"
        "hyprlang"
        "hyprpolkitagent"
    )

    # Wayland utilities
    local wayland_packages=(
        "waybar"
        "rofi-wayland"
        "swaync"
        "wlogout"
        "swww"
        "waypaper"
        "grim"
        "slurp"
        "grimblast-git"
        "wl-clipboard"
        "cliphist"
        "nwg-look"
        "qt6ct"
        "qt5ct"
        "nwg-dock-hyprland"
        "wayland"
        "wayland-protocols"
    )

    # System utilities
    local system_packages=(
        "polkit-gnome"
        "brightnessctl"
        "pavucontrol"
        "power-profiles-daemon"
        "uwsm"
        "playerctl"
        "network-manager-applet"
        "nm-connection-editor"
        "blueman"
        "flatpak"
        "gvfs"
        "gvfs-smb"
        "systemd"
        "dbus"
        "networkmanager"
        "bluetooth"
        "bluez"
        "bluez-utils"
        "bluez-libs"
    )

    # Audio system (PipeWire)
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "pipewire-jack"
        "wireplumber"
        "pavucontrol"
        "playerctl"
        "alsa-utils"
        "alsa-firmware"
    )

    # Theme and appearance
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
        "hicolor-icon-theme"
        "gtk3"
        "gtk4"
        "gtk-layer-shell"
    )

    # Development tools
    local dev_packages=(
        "git"
        "base-devel"
        "cmake"
        "ninja"
        "python"
        "python-pip"
        "python-gobject"
        "python-screeninfo"
        "nodejs"
        "npm"
    )

    # Fonts
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
        "ttf-liberation"
        "cantarell-fonts"
    )

    # Essential CLI tools
    local cli_tools=(
        "zsh"
        "fzf"
        "z"
        "bat"
        "eza"
        "vim"
        "neovim"
        "fd"
        "thefuck"
        "zoxide"
        "bind"
        "htop"
        "curl"
        "wget"
        "unzip"
        "unrar"
        "zip"
        "tar"
        "rsync"
    )

    # Terminal and shell
    local terminal_packages=(
        "kitty"
        "zsh"
        "bash-completion"
        "zsh-completions"
	"oh-my-posh"
    )

    # File management
    local file_packages=(
        "nautilus"
        "tumbler"
        "loupe"
        "file-roller"
        "gparted"
    )

    # Applications
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
        "pinta"
        "qbittorrent"
    )

    # System monitoring and maintenance
    local system_monitor=(
        "checkupdates-with-aur"
        "pacseek"
        "downgrade"
        "reflector-simple"
        "htop"
        "fastfetch"
        "inxi"
    )

    # Network and VPN
    local network_packages=(
        "nordvpn-bin"
        "nordvpn-gui"
        "networkmanager-openvpn"
        "networkmanager-openconnect"
    )

    # Hardware-specific packages
    local nvidia_packages=()
    local amd_packages=()
    
    if [ "$HAS_NVIDIA" = true ]; then
        nvidia_packages=(
            "nvidia-open-dkms"
            "nvidia-utils"
            "lib32-nvidia-utils"
        )
    fi
    
    if [ "$HAS_AMD" = true ]; then
        amd_packages=(
            "mesa"
            "lib32-mesa"
            "vulkan-radeon"
            "lib32-vulkan-radeon"
            "xf86-video-amdgpu"
            "xf86-video-ati"
        )
    fi

    # Install packages by category
    local categories=(
        "Core System:core_system"
        "Hyprland:hyprland_packages"
        "Wayland:wayland_packages"
        "System:system_packages"
        "Audio:audio_packages"
        "Themes:theme_packages"
        "Development:dev_packages"
        "Fonts:font_packages"
        "CLI Tools:cli_tools"
        "Terminal:terminal_packages"
        "File Management:file_packages"
        "Applications:app_packages"
        "System Monitor:system_monitor"
        "Network:network_packages"
    )
    
    if [ "$HAS_NVIDIA" = true ]; then
        categories+=("NVIDIA:nvidia_packages")
    fi
    
    if [ "$HAS_AMD" = true ]; then
        categories+=("AMD:amd_packages")
    fi

    for category_info in "${categories[@]}"; do
        local category_name="${category_info%:*}"
        local package_array_name="${category_info#*:}"
        
        log_progress "Installing $category_name packages..."
        
        # Get reference to array
        local -n package_array=$package_array_name
        
        for package in "${package_array[@]}"; do
            install_single_package "$package" "$category_name"
        done
        
        log_success "$category_name packages installation completed"
    done
}

# Remove conflicting packages
remove_packages() {
    local packages_to_remove=(
        "firefox"
        "ml4w-hyprland"
        "dunst"
    )
    
    local failed_removals=()
    
    log_progress "Removing conflicting packages..."
    for package in "${packages_to_remove[@]}"; do
        if [[ $(_isInstalled "${package}") == 0 ]]; then
            log_info "Removing $package..."
            if yay -Rns --noconfirm "$package" 2>/dev/null; then
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

# Install additional tools
install_additional_tools() {
    # Create local bin directory
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi

    log_info "Additional tools directory created at ~/.local/bin"
    
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        log_info "Added ~/.local/bin to PATH in ~/.bashrc"
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
        "$HOME/.config/kitty"
        "$HOME/.themes"
        "$HOME/.icons"
    )
    
    log_progress "Creating directories..."
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

# Detect device type based on hardware or hostname
detect_device_type() {
    local device_type="desktop"  # default
    
    # Method 1: Check for laptop indicators
    if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
        device_type="laptop"
        log_info "Laptop detected (battery found)"
    # Method 2: Check hostname patterns (customize these for your machines)
    elif [[ "$(hostname)" == *"laptop"* ]] || [[ "$(hostname)" == *"portable"* ]]; then
        device_type="laptop"
        log_info "Laptop detected (hostname pattern)"
    # Method 3: Check for laptop-specific hardware
    elif command_exists "laptop-detect" && laptop-detect; then
        device_type="laptop"
        log_info "Laptop detected (laptop-detect tool)"
    # Method 4: Check DMI information
    elif [ -r "/sys/class/dmi/id/chassis_type" ]; then
        local chassis_type=$(cat /sys/class/dmi/id/chassis_type)
        # Chassis types: 8=Portable, 9=Laptop, 10=Notebook, 14=Sub Notebook
        if [[ "$chassis_type" =~ ^(8|9|10|14)$ ]]; then
            device_type="laptop"
            log_info "Laptop detected (DMI chassis type: $chassis_type)"
        fi
    fi
    
    # Export for use in other functions
    export DEVICE_TYPE="$device_type"
    log_info "Device type set to: $device_type"
}

# Create symbolic links with enhanced error handling
create_symlinks() {
    # Determine Waybar config file based on device type
    local waybar_config_file=""
    if [ "$DEVICE_TYPE" = "laptop" ]; then
        waybar_config_file="config-laptop"
        log_info "Using laptop-specific Waybar configuration"
    else
        waybar_config_file="config-desktop"
        log_info "Using desktop-specific Waybar configuration"
    fi

    # Determine Rofi font config file based on device type
    local rofi_font_config_file=""
    if [ "$DEVICE_TYPE" = "laptop" ]; then
	    rofi_font_config_file="rofi-font-laptop.rasi"
	    log_info "Using laptop-specific Rofi font configuration"
    else
	    rofi_font_config_file="rofi-font-desktop.rasi"
	    log_info "Using desktop-specific Rofi font configuration"
    fi
    
    # Check if device-specific config exists, fallback to generic
    if [ ! -f "$REPO_DIR/.config/waybar/themes/ml4w-modern/$waybar_config_file" ]; then
        log_warning "Device-specific Waybar config not found: $waybar_config_file"
        if [ -f "$REPO_DIR/.config/waybar/themes/ml4w-modern/config" ]; then
            waybar_config_file="config"
            log_info "Falling back to generic Waybar config"
        else
            log_error "No Waybar config file found!"
        fi
    fi

    if [ ! -f "$REPO_DIR/.config/ml4w/settings/$rofi_font_config_file" ]; then
	    log_warning "Device-specific Rofi font config not found: $rofi_font_config_file"
	    if [ -f "$REPO_DIR/.config/ml4w/settings/rofi-font.rasi" ]; then
		    rofi_font_config_file="rofi-font.rasi"
		    log_info "Falling back to generic Rofi font config"
	    else
		    log_error "No Rofi font config file found!"
	    fi
    fi
    
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
        ["$REPO_DIR/.config/hypr/conf/keybinding.conf"]="$HYPR_HOME/conf/keybinding.conf"
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
        
        # Waybar configuration (device-specific)
        ["$REPO_DIR/.config/waybar/modules.json"]="$WAYBAR_HOME/modules.json"
        ["$REPO_DIR/.config/waybar/launch.sh"]="$WAYBAR_HOME/launch.sh"
        ["$REPO_DIR/.config/waybar/themes/ml4w-modern/$waybar_config_file"]="$WAYBAR_HOME/themes/ml4w-modern/config"
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
        ["$REPO_DIR/.config/ml4w/settings/$rofi_font_config_file"]="$HOME/.config/ml4w/settings/$rofi_font_config_file"
        ["$REPO_DIR/.config/ml4w/settings/screenshot-folder.sh"]="$HOME/.config/ml4w/settings/screenshot-folder.sh"
        ["$REPO_DIR/.config/ml4w/settings/sddm/theme.tpl"]="$HOME/.config/ml4w/settings/sddm/theme.tpl"
        
        # Kitty configuration
        ["$REPO_DIR/.config/kitty/colors-matugen.conf"]="$HOME/.config/kitty/colors-matugen.conf"
        ["$REPO_DIR/.config/kitty/colors-wallust.conf"]="$HOME/.config/kitty/colors-wallust.conf"
        ["$REPO_DIR/.config/kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    )
    
    local failed_symlinks=()
    local success_count=0
    
    log_progress "Creating symbolic links..."
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
            log_info "Created symlink: $(basename "$target")"
            ((success_count++))
        else
            log_error "Failed to create symlink: $target -> $source"
            failed_symlinks+=("$source -> $target")
        fi
    done
    
    if [ ${#failed_symlinks[@]} -ne 0 ]; then
        log_warning "Failed to create ${#failed_symlinks[@]} symlinks:"
        printf '%s\n' "${failed_symlinks[@]}"
    fi
    
    log_success "Created $success_count symlinks successfully"

    # Make scripts executable
    if [ -d "$HYPR_HOME/scripts" ]; then
        chmod +x "$HYPR_HOME/scripts/"*.sh 2>/dev/null || true
        log_info "Made Hyprland scripts executable"
    fi
    if [ -d "$WAYBAR_HOME" ]; then
        chmod +x "$WAYBAR_HOME/"*.sh 2>/dev/null || true
        log_info "Made Waybar scripts executable"
    fi
}

# Enable systemd services
enable_services() {
    local services=(
        "bluetooth.service"
        "power-profiles-daemon.service"
        "NetworkManager.service"
    )
    
    log_progress "Enabling systemd services..."
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
        
        # Start service if not running
        if ! systemctl is-active --quiet "$service"; then
            if sudo systemctl start "$service"; then
                log_info "Started $service"
            else
                log_warning "Failed to start $service"
            fi
        fi
    done
}

# Verify installation and generate report
verify_installation() {
    log_progress "Verifying installation..."
    
    local total_packages=$((${#INSTALLED_PACKAGES[@]} + ${#FAILED_PACKAGES[@]}))
    
    echo
    echo -e "${GREEN}=== INSTALLATION REPORT ===${NC}"
    echo -e "${GREEN}Successfully installed: ${#INSTALLED_PACKAGES[@]} packages${NC}"
    echo -e "${RED}Failed installations: ${#FAILED_PACKAGES[@]} packages${NC}"
    echo -e "${BLUE}Total packages processed: $total_packages${NC}"
    
    if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
        echo
        echo -e "${RED}Failed packages:${NC}"
        printf '%s\n' "${FAILED_PACKAGES[@]}" | sort
        
        # Save failed packages to file for later retry
        printf '%s\n' "${FAILED_PACKAGES[@]}" > "$HOME/.dotfiles_failed_packages"
        log_info "Failed packages list saved to ~/.dotfiles_failed_packages"
    fi
    
    # Check critical services
    echo
    echo -e "${CYAN}=== SERVICE STATUS ===${NC}"
    local critical_services=("bluetooth" "NetworkManager" "power-profiles-daemon")
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "${GREEN}✓${NC} $service is running"
        else
            echo -e "${RED}✗${NC} $service is not running"
        fi
    done
}

# Print final instructions
print_instructions() {
    log_success "Dotfiles setup completed!"
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
    echo "  - oh-my-posh init zsh: Initialize Oh My Posh for zsh"
    echo
    
    if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
        log_warning "Some packages failed to install. You can retry with:"
        echo "  yay -S \$(cat ~/.dotfiles_failed_packages | tr '\n' ' ')"
    fi
    
    echo -e "${GREEN}=== HARDWARE CONFIGURATION ===${NC}"
    if [ "$HAS_NVIDIA" = true ]; then
        echo "• NVIDIA GPU detected - NVIDIA drivers were installed"
    fi
    if [ "$HAS_AMD" = true ]; then
        echo "• AMD GPU detected - AMD drivers were installed"
    fi
}

# Cleanup function
cleanup() {
    if [ -d "$HOME/Downloads/yay-bin" ]; then
        rm -rf "$HOME/Downloads/yay-bin"
    fi
    log_info "Cleanup completed"
}

# Main execution
main() {
    # Set trap for cleanup
    trap cleanup EXIT
    
    log_info "Starting enhanced dotfiles setup script..."
    
    # Header
    echo -e "${GREEN}"
    cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF
    echo "Enhanced Dotfiles Setup for Hyprland"
    echo -e "${NC}"
    
    # Detect hardware early
    detect_hardware
    detect_device_type
    
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
    
    # Main installation steps
    check_dependencies
    setup_dotfiles_repo
    remove_packages
    install_packages
    install_additional_tools
    create_directories
    create_symlinks
    enable_services
    verify_installation
    print_instructions
    
    log_success "Installation completed successfully!"
}

# Run main function
main "$@"
