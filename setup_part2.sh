#!/bin/bash

# Check if git is installed (essential for cloning)
if ! command -v git &> /dev/null; then
	echo "Error: git is required. Please install git and try again."
	exit 1
fi

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
	"dig"
	"zen-browser-bin"
	"megasync-bin"
	"obsidian"
	"spicetify-cli"
	"pywal-spicetify"
	"discord"
	"spotify-launcher"
	"steam"
	"python-dbus-fast"
	"python-pybluez"
	"bluez"
	"bluez-libs"
	"bluez-utils"
	"blueman"
	"lxappearance"
	"python-netifaces"
	"oh-my-posh-bin"
	"fastfetch"
	"thunar-shares-plugin"
	"gvfs"
	"gvfs-smb"
	"gimp"
	"nordvpn-bin"
	"nordtray-bin"
	"nordtray-executable-symlink-latest"
	"polkit-gnome"
	"seahorse"
	"polkit"
	"gparted"
	"htop"
	"lm_sensors"
	"mpv"
	"qbittorrent"
	"obs-studio"
	"wowup-cf-bin"
	"ttf-jetbrains-mono-nerd"
	"qt6-5compat"
	"betterlockscreen"
	"qt6ct"
	"bibata-cursor-theme"
	"papirus-icon-theme"
	"cronie"
)

# Install packages
echo "Installing packages..."
for package in "${packages[@]}"; do
	if ! pacman -Q "$package" &> /dev/null; then
		echo "Installing $package..."
		yay -S "$package"
		if [[ $? -eq 0 ]]; then
			echo "$package installed succesfully."
		else
			echo "Error installing $package. Check the yay output for details."
			exit 1
		fi
	else
		echo "$package is already installed."
	fi
done

if [ "$(hostname)" == "arch-desktop" ]; then
	if ! pacman -Q "nvidia-dkms" &> /dev/null; then
		yay -S "nvidia-dkms"
	fi
fi

echo "Finished checking and installing packages."

# Starting needed services
sudo systemctl enable --now bluetooth
sudo systemctl enable --now cronie
sudo systemctl enable --now nordvpnd

# Themeing
cd $HOME/Documents/git
git clone --depth=1 https://github.com/spicetify/spicetify-themes.git
cd spicetify-themes/
mkdir -p $HOME/.config/spicetify/Themes
cp -r * $HOME/.config/spicetify/Themes

# Setting up SDDM
sddm_theme_name="sequoia"
sddm_theme_master="main.zip"
sddm_theme_folder="sddm-sequoia"
sddm_theme_download="https://codeberg.org/minMelody/sddm-sequoia/archive/main.zip"
sddm_asset_folder="/usr/share/sddm/themes/$sddm_theme_name/backgrounds"
# sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sequoia

sddm_theme_tpl="$HOME/Documents/git/dotfiles/usr/share/sddm/theme.conf"

if [ -z $automation_displaymanager ]; then
	if [ -d /usr/share/sddm ]; then
        	if [ -d "$HOME/Documents/git/$sddm_theme_name" ]; then
                	rm -rf "$HOME/Documents/git/$sddm_theme_name"
            	fi

            	wget -P "$HOME/Documents/git/$sddm_theme_name" $sddm_theme_download
            	unzip -o -q "$HOME/Documents/git/$sddm_theme_name/$sddm_theme_master" -d "$HOME/Documents/git/$sddm_theme_name"

            	sudo cp -r "$HOME/Documents/git/$sddm_theme_name/$sddm_theme_folder" "/usr/share/sddm/themes/$sddm_theme_name"

            	if [ ! -d /etc/sddm.conf.d/ ]; then
                	sudo mkdir /etc/sddm.conf.d
            	fi

            	sudo cp "$HOME/Documents/git/dotfiles/usr/share/sddm/sddm.conf" "/etc/sddm.conf.d/"

            	if [ -f /usr/share/sddm/themes/$sddm_theme_name/theme.conf ]; then

                	# Cache file for holding the current wallpaper
                	sudo cp "$HOME/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg" "$sddm_asset_folder/current_wallpaper.jpg"

                	sudo cp $sddm_theme_tpl /usr/share/sddm/themes/$sddm_theme_name/
                	sudo sed -i 's/CURRENTWALLPAPER/'"current_wallpaper.jpg"'/' /usr/share/sddm/themes/$sddm_theme_name/theme.conf
            	fi
        fi
fi

# Array of packages to remove
packages_to_remove=(
	"firefox"
	"neovim"
	"xorg-server-devel"
	"xorg-server-xephyr"
	"xorg-server-xnest"
	"xorg-server-xvfb"
	"xorg-docs"
	"xorg-fonts-100dpi"
	"xorg-fonts-75dpi"
	"jfsutils"
	"nilfs-utils"
	"paru-bin"
)

# Remove packages
echo "Removing packages..."
for package in "${packages_to_remove[@]}"; do
	if pacman -Q "$package"	&> /dev/null; then
		echo "Removing $package..."
		yay -Rns --noconfirm "$package"
		if [[ $? -eq 0 ]]; then
			echo "$package removed succesfully."
		else
			echo "Error removing $package. Check the yay output for details."
			exit 1
		fi
	else
		echo "$package is not installed."
	fi
done

echo "Finished removing packages."

# Creating directories (using -p for parent directories)
echo "Creating directories..."
mkdir -p "$HOME/Documents/git/fzf-git.sh"
mkdir -p "$HOME/.config/qtile"
mkdir -p "$HOME/.config/ohmyposh"
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/picom"
echo "Finished creating directories."

# Setting links
echo "Creating symbolic links..."
ln -sf "$HOME/Documents/git/dotfiles/.bashrc" "$HOME/"
ln -sf "$HOME/Documents/git/dotfiles/git/fzf-git.sh/fzf-git.sh" "$HOME/Documents/git/fzf-git.sh/"
ln -sf "$HOME/Documents/git/dotfiles/.config/qtile/config.py" "$HOME/.config/qtile/"
ln -sf "$HOME/Documents/git/dotfiles/.config/qtile/network_status.py" "$HOME/.config/qtile/"
ln -sf "$HOME/Documents/git/dotfiles/.config/ohmyposh/EDM115-newline.omp.json" "$HOME/.config/ohmyposh/"
ln -sf "$HOME/Documents/git/dotfiles/.config/alacritty/colors.toml" "$HOME/.config/alacritty/"
ln -sf "$HOME/Documents/git/dotfiles/.config/qtile/autostart_once.sh" "$HOME/.config/qtile/"
ln -sf "$HOME/Documents/git/dotfiles/.config/picom/picom.conf" "$HOME/.config/picom"
ln -sf "$HOME/Documents/git/dotfiles/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/"
sudo cp "$HOME/Documents/git/dotfiles/reflector-simple.conf" "/etc/"
echo "Finished creating symbolic links."
echo "Script completed."
