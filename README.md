# HyDE Custom Configuration

Custom configuration for [HyDE (HyprLand Desktop Environment)](https://github.com/HyDE-Project/HyDE) featuring the Tokyo Night theme and personalized Hyprland setup.

## 🎨 Features

### Tokyo Night Theme
- **Dark aesthetic** with vibrant purple/pink accents
- **Custom wallpapers** including animated gaming room GIF
- **Coordinated color scheme** across all components

### Enhanced Components
- **Hyprland**: Custom keybindings and window management
- **Waybar**: Personalized layouts (`hellia.jsonc`) and modules (`clock.jsonc`)
- **Applications**: Pre-configured desktop entries (Obsidian)
- **Scripts**: Additional utilities including fzf-git integration

### Package Extensions
- **Custom package list** (`pkg_user.lst`) with development and productivity tools
- **Seamless integration** with HyDE's package management

## 📋 Prerequisites

- **Arch Linux** (or Arch-based distribution)
- **Minimal installation** recommended
- **Internet connection** for downloading packages
- **Git** installed

## 🚀 Installation

### Automated
```bash
curl -sSL https://raw.githubusercontent.com/hellia-be/dotfiles/main/setup.sh | bash
```

### Manual
#### Step 1: Install Base Arch Linux
Install Arch Linux with a minimal setup (base system + basic utilities).

#### Step 2: Prepare Custom Package List
```bash
# Clone this repository
git clone https://github.com/hellia-be/dotfiles ~/hyde-custom
```

#### Step 3: Install HyDE with Custom Packages
```bash
# Install HyDE
git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
cd ~/HyDE/Scripts
cp ~/hyde-custom/HyDE/Scripts/pkg_user.lst ./
cp ~hyde-custom/HyDE/Scripts/pkg_core.lst ./
./install.sh pkg_user.lst
```

#### Step 4: Activate Theme
1. **Log out and log back in** (or restart your session)
2. **Open HyDE theme selector**: `Super + Ctrl + T` or from the application menu
3. **Select "Tokyo Night"** from the available themes
4. **Apply the theme** and enjoy your customized setup


#### Step 5: Apply Custom Configuration
```bash
cd ~
cp hyde-custom/.config/fastfetch/logo/* .config/fastfetch/logo/
cp hyde-custom/.config/hyde/themes/Tokyo\ Night/wallpapers/gaming_room.gif .config/hyde/themes/Tokyo\ Night/wallpapers/
cp hyde-custom/.config/hypr/keybindings.conf .config/hypr/
cp hyde-custom/.config/hypr/themes/theme.conf .config/hypr/themes/
cp hyde-custom/.config/hypr/userprefs.conf .config/hypr/
cp hyde-custom/.config/hypr/windowrules.conf .config/hypr/
cp hyde-custom/.local/share/hypr/variables.conf .local/share/hypr/
cp hyde-custom/.local/share/waybar/layouts/hellia.jsonc .local/share/waybar/layouts/
cp hyde-custom/.local/share/waybar/modules/* .local/share/waybar/modules/
cp hyde-custom/.local/state/hyde/config .local/state/hyde/
sudo cp hyde-custom/etc/ly/config.ini /etc/ly/
```

## 🔧 What Gets Installed

### Symlinked Configurations (Live Updates)
- `~/.config/hyde/themes/Tokyo Night/` → Tokyo Night theme files
- `~/.config/hypr/keybindings.conf` → Custom key bindings
- `~/.config/hypr/userprefs.conf` → User preferences
- `~/.config/hypr/themes/theme.conf` → Theme-specific settings
- `~/.local/share/waybar/layouts/hellia.jsonc` → Custom waybar layout
- `~/.local/share/waybar/modules/clock.jsonc` → Custom clock module
- `~/.local/state/hyde/config` → HyDE state configuration
- `~/.local/bin/*.sh` → Custom utility scripts

### Copied Files
- `~/.config/hyde/pkg_user.lst` → Custom package list for HyDE

## 🔄 Updating Configuration

Since configurations are symlinked to the repository, updates are simple:

```bash
# Navigate to the config repository
cd ~/.hyde-custom

# Pull latest changes
git pull

# Copy over the files
cp hyde-custom/.config/fastfetch/logo/* .config/fastfetch/logo/
cp hyde-custom/.config/hyde/themes/Tokyo\ Night/wallpapers/gaming_room.gif .config/hyde/themes/Tokyo\ Night/wallpapers/
cp hyde-custom/.config/hypr/keybindings.conf .config/hypr/
cp hyde-custom/.config/hypr/themes/theme.conf .config/hypr/themes/
cp hyde-custom/.config/hypr/userprefs.conf .config/hypr/
cp hyde-custom/.config/hypr/windowrules.conf .config/hypr/
cp hyde-custom/.local/share/hypr/variables.conf .local/share/hypr/
cp hyde-custom/.local/share/waybar/layouts/hellia.jsonc .local/share/waybar/layouts/
cp hyde-custom/.local/share/waybar/modules/* .local/share/waybar/modules/
cp hyde-custom/.local/state/hyde/config .local/state/hyde/
sudo cp hyde-custom/etc/ly/config.ini /etc/ly/

# Configurations update automatically via symlinks!
# Restart applications if needed:
hyprctl reload  # Reload Hyprland
pkill waybar && waybar &  # Restart waybar
```

## 📁 Repository Structure

```
.
├── .config/
│   ├── fastfetch/
│   │   └── logo/
│   │       ├── vecteezy_44646944.png
│   │       ├── vecteezy_44646948.png
│   │       ├── vecteezy_44778359.png
│   │       ├── vecteezy_44778365.png
│   │       ├── vecteezy_44607086.png
│   │       ├── vecteezy_23338699.png
│   │       └── vecteezy_23573750.png
│   ├── hyde/
│   │   └── themes/
│   │       └── Tokyo Night/
│   │           └── wallpapers/
│   │               └── gaming_room.gif
│   └── hypr/
│       ├── keybindings.conf
│       ├── userprefs.conf
        ├── windowrules.conf
│       └── themes/
│           └── theme.conf
├── .local/
│   ├── share/
│   │   └── waybar/
│   │       ├── layouts/
│   │       │   └── hellia.jsonc
│   │       └── modules/
│   │           ├── pulseaudio.jsonc
│   │           └── clock.jsonc
│   └── state/
│       └── hyde/
│           └── config
├── HyDE/
│   └── Scripts/
│       ├── pkg_core.lst
│       └── pkg_user.lst
├── /etc/
│   └── ly/
│       └── config.ini
└── README.md
```

## 🎯 Key Features

### Custom Keybindings
- Enhanced window management
- Quick application launchers
- Media controls integration

### Waybar Customization
- **Hellia Layout**: Personalized bar arrangement
- **Custom Clock**: Enhanced time/date display
- **Theme Integration**: Matches Tokyo Night aesthetic

### Development Tools
- **fzf-git**: Enhanced git workflow with fuzzy finding
- **Obsidian**: Pre-configured for note-taking
- **Additional packages**: See `pkg_user.lst` for full list

## 🛠️ Troubleshooting

### Installation Issues
```bash
# Check HyDE installation
ls -la ~/.config/hyde/

# Verify symlinks
ls -la ~/.config/hypr/

# Check logs
tail -f ~/hyde-custom-install.log
```

### Theme Not Showing
1. Ensure HyDE is properly installed
2. Restart your session completely
3. Use HyDE theme selector: `Super + Ctrl + T`
4. Check if Tokyo Night appears in theme list

### Updates Not Working
```bash
# Check repository status
cd ~/.hyde-custom
git status
git pull

# Verify symlinks are intact
ls -la ~/.config/hypr/hyprland.conf
```

## 🔄 Rollback

The installer creates automatic backups:
```bash
# Check backup location (shown during installation)
ls -la ~/.hyde-custom-backup-*

# Restore from backup if needed
cp -r ~/.hyde-custom-backup-*/hypr/* ~/.config/hypr/
```

## 🎨 Customization

### Adding Your Own Wallpapers
```bash
cd ~/.hyde-custom-config/.config/hyde/themes/Tokyo\ Night/wallpapers/
# Add your wallpapers here
git add . && git commit -m "Add custom wallpapers"
git push
```

### Modifying Keybindings
```bash
# Edit keybindings (changes reflect immediately via symlinks)
vim ~/.config/hypr/keybindings.conf
# Or edit in the repository:
vim ~/.hyde-custom-config/.config/hypr/keybindings.conf
```

## 🤝 Contributing

1. **Fork** this repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Based on HyDE
- [HyDE Project](https://github.com/HyDE-Project/HyDE) - The foundation for this customization

### Inspirations
- [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
- [prasanthrangan/hyprdots](https://github.com/prasanthrangan/hyprdots)
- [sudo-harun/dotfiles](https://github.com/sudo-harun/dotfiles)
- [dianaw353/hyprland-configuration-rootfs](https://github.com/dianaw353/hyprland-configuration-rootfs)
- [mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/hellia-be/dotfiles/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hellia-be/dotfiles/discussions)
- **HyDE Support**: [HyDE Discord](https://discord.gg/hydeproject)

---

**Enjoy your customized HyDE setup! 🎉**
