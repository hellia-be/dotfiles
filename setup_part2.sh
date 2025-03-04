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
	"nvidia-dkms"
	"qbittorrent"
	"obs-studio"
	"wowup-cf-bin"
)

# Install packages
echo "Installing packages..."
for package in "${packages[@]}"; do
	if ! pacman -Q "$package" &> /dev/null; then
		echo "Installing $package..."
		yay -S --noconfirm "$package"
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
sudo cp "$HOME/Documents/git/dotfiles/reflector-simple.conf" "/etc/"
echo "Finished creating symbolic links."
echo "Script completed."
