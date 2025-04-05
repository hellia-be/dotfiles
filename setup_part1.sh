#!/bin/bash

# Check if git is installed (essential for cloning)
if ! command -v git &> /dev/null; then
	echo "Error: git is required. Please install git and try again."
	exit 1
fi

# Cleaning up base install
sudo pacman -Rns eos-hooks
packages=(
	"archlinux-keyring"
	"bash"
	"bzip2"
	"lsb-release"
	"coreutils"
	"file"
	"filesystem"
	"findutils"
	"gawk"
	"gcc-libs"
	"gettext"
	"glibc"
	"grep"
	"gzip"
	"iproute2"
	"iputils"
	"licenses"
	"pacman"
	"pciutils"
	"procps-ng"
	"psmisc"
	"sed"
	"shadow"
	"systemd"
	"systemd-sysvcompat"
	"tar"
	"util-linux"
	"xz"
	"linux"
)

echo "Reinstalling packages on Arch base..."
for package in "${packages[@]}"; do
	echo "Installing $package..."
	sudo pacman -Syy "$package"
	if [[ $? -eq 0 ]]; then
		echo "$package installed successfully."
	else
		echo "Error installing $package. Check the pacman output for details."
		exit 1
	fi
done
echo "Finished reinstalling packages on Arch base..."

# Define the repository URL and directory
repo_url="https://github.com/hellia-be/dotfiles.git"
repo_dir="$HOME/Documents/git/dotfiles"

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

# Adapting the pacman.conf to a clean Arch base
sudo cp "$HOME/Documents/git/dotfiles/pacman.conf" "/etc/pacman.conf"

# Removing extra packages
packages_to_remove=(
	"endeavouros-keyring"
	"endeavouros-mirrorlist"
)

echo "Removing last EndeavourOS packages..."
for package in "${packages_to_remove[@]}"; do
	if pacman -Q "$package" &> /dev/null; then
		echo "Removing $package..."
		yay -Rns --noconfirm "$package"
		if [[ $? -eq 0 ]]; then
			echo "$package removed successfully."
		else
			echo "Error removing $package. Check the yay output for details."
			exit 1
		fi
	else
		echo "$package is not installed."
	fi
done
echo "Finished removing packages."

# Reinstalling needed Arch base packages
packages=(
	"kernel-install-for-dracut"
	"reflector-simple"
)
for package in "${packages[@]}"; do
	echo "Installing $package..."
	yay -S $package
	if [[ $? -eq 0 ]]; then
		echo "$package installed successfully."
	else
		echo "Error installing $package. Check the yay output for details."
	fi
done
echo "Finished installing packages..."

if [ "$(hostname)" != "plex" ]; then
	# Check for ml4w-hyprland and run setup if needed
	if ! command -v qtile &> /dev/null; then
		echo "qtile is not installed. Installing..."
		# Install it using Cozytile
		mkdir -p $HOME/Documents/git
		cd $HOME/Documents/git
		git clone https://github.com/Darkkal44/Cozytile
		cd Cozytile
		chmod +x install.sh
		./install.sh
	fi
fi
echo "Script completed."
