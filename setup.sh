#!/bin/bash

# Check if git is installed (essential for cloning)
if ! command -v git &> /dev/null; then
	echo "Error: git is required. Please install git and try again."
	exit 1
fi

# Define the repository URL and directory
repo_url="https://github.com/hellia-be/dotfiles.git"
repo_dir="$HOME/git/dotfiles"

# Check if the repository directory already exists
if [ ! -d "$repo_dir" ]; then
	# Clone the repository
	echo "Cloning dotfiles repository..."
	git clone "$repo_url" "$repo_dir"
	if [[ $? -ne 0 ]]; then
		echo "Error: Failed to clone repository. Check the URL and your internet connection."
		exit 1
	fi
else
	echo "Dotfiles repository already exists. Skipping clone."
	cd "$repo_dir" && git pull origin main
fi

# Check for ml4w-hyprland and run setup if needed
if ! command -v ml4w-hyprland-setup &> /dev/null; then
	echo "ml4w-hyprland is not installed. Installing..."
	# Install it using yay
	if command -v yay &> /dev/null; then
		yay -S --noconfirm ml4w-hyprland
		if [[ $? -ne 0 ]]; then
			echo "Error installing ml4w-hyprland"
			exit 1
		fi
	# Manual installation
	else
		bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)
	fi
else
	if ! [ -f "$HOME/.config/ml4w/settings/browser.sh" ]; then
		echo "ml4w-hyprland-setup hasn't been run. Running setup..."
		ml4w-hyprland-setup
		if [[ $? -eq 0 ]]; then
			echo "ml4w-hyprland-setup completed."
		else
			echo "Error: ml4w-hyprland-setup failed. Please check its output for more details."
			exit 1
		fi
	else
		echo "ml4w-hyprland-setup has already been run. Updating current setup."
		ml4w-hyprland-setup -m update
		if [[ $? -eq 0 ]]; then
			echo "ml4w-hyprland-setup updated."
		else
			echo "Error: ml4w-hyprland-setup -m update failed. Please check its output for more details."
			exit 1
		fi
	fi
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
	"hyprpolkitagent"
	"zen-browser-bin"
	"megasync-bin"
	"obsidian"
	"spicetify-cli"
	"pywal-spicetify"
	"vesktop-bin"
	"ttf-3270-nerd"
	"spotify-launcher"
	"steam"
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

# Array of packages to remove
packages_to_remove=(
	"gnome-polkit"
	"firefox"
	"neovim"
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
mkdir -p "$HOME/git/fzf-git.sh"
mkdir -p "$HOME/.config/hypr/scripts"
mkdir -p "$HOME/.config/hypr/conf/keybindings"
mkdir -p "$HOME/.config/hypr/conf/windowrules"
mkdir -p "$HOME/.config/ml4w/settings/sddm"
mkdir -p "$HOME/.config/waybar/themes/ml4w-modern"
mkdir -p "$HOME/.config/hypr/conf/monitors"
echo "Finished creating directories."

# Setting links
echo "Creating symbolic links..."
ln -sf "$HOME/git/dotfiles/.bashrc_custom" "$HOME/"
ln -sf "$HOME/git/dotfiles/git/fzf-git.sh/fzf-git.sh" "$HOME/git/fzf-git.sh/"
ln -sf "$HOME/git/dotfiles/.config/hypr/scripts/screenshot.sh" "$HOME/.config/hypr/scripts/"
ln -sf "$HOME/git/dotfiles/.config/hypr/scripts/resume-lock.sh" "$HOME/.config/hypr/scripts/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/autostart.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/cursor.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/keybindings/default.conf" "$HOME/.config/hypr/conf/keybindings/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/keyboard.conf" "$HOME/.config/hypr/conf/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/windowrules/default.conf" "$HOME/.config/hypr/conf/windowrules/"
ln -sf "$HOME/git/dotfiles/.config/ml4w/settings/browser.sh" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/git/dotfiles/.config/ml4w/settings/rofi-font.rasi" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/git/dotfiles/.config/ml4w/settings/screenshot-folder.sh" "$HOME/.config/ml4w/settings/"
ln -sf "$HOME/git/dotfiles/.config/ml4w/settings/sddm/theme.tpl" "$HOME/.config/ml4w/settings/sddm/"
ln -sf "$HOME/git/dotfiles/.config/waybar/modules.json" "$HOME/.config/waybar/"
ln -sf "$HOME/git/dotfiles/.config/waybar/themes/ml4w-modern/config" "$HOME/.config/waybar/themes/ml4w-modern/"
ln -sf "$HOME/git/dotfiles/.config/waybar/themes/ml4w-modern/style.css" "$HOME/.config/waybar/themes/ml4w-modern/"
ln -sf "$HOME/git/dotfiles/.config/hypr/conf/monitors/default.conf" "$HOME/.config/hypr/conf/monitors/"
echo "Finished creating symbolic links."
echo "Script completed."
