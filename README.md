# Dotfiles for Hyprland

Configuration for Arch Linux based distributions. This package includes an installation script to install and set up the required components.

## Main Packages

- Terminal: kitty
- Editor: vim
- Prompt: oh-my-posh
- Wallpaper: hyprpaper with waypaper
- Icons: Font Awesome and Papirus-Icon-Theme
- Launch Menus: Rofi (Wayland)
- Color Theme: pywal
- Browser: Zen Browser
- Filemanager: Nautilus and yazi
- Cursor: Bibata Modern Ice
- Status Bar: waybar
- Screenshots: grim, slurp and grimblast
- Logout: wlogout
- Idle Manager: hypridle
- Screenlock: hyprlock
- GTK Theme Manager: nwg-look
- QT6 Theme Manager: qt6ct
- Font: 3270 Nerd Font

## Installation

The installation works on Arch Linux distributions.

> IMPORTANT: Please make sure that all packages on your system are updated before running the installation script.

> PLEASE NOTE: Every Linux distribution, setup, and personal configuration can be different. Therefore, I can't guarantee that these dotfiles will work everywhere. You install at your own risk.

```shell
bash <(curl -s https://raw.githubusercontent.com/hellia-be/dotfiles/main/setup.sh)
```

Please rebuild all packages to ensure that you get the latest commit.

## Troubleshooting

### Issues with SDDM Sequoia Theme

If you notice an error with the Sequoia theme, you can uninstall the theme with

```shell
sudo rm -rf /usr/share/sddm/themes/sequoia
```

### Wrong Timezone in Waybar

```shell
yay -S downgrade
sudo downgrade tzdata
```

select 2024a-2

Downgrade tzdata to 2024a-2 and reboot will fix the issue.

Using downgrade, it is important to click yes when asked about the "no update". Otherwise, it will revert back to UTC after reboot.

### Waybar is not Loading

The fact that waybar isn't loading usually happens after a fresh installation of these dotfiles. The reason is the start of xdg-desktop-portal-gtk process. It can also happen when you start Hyprland from the TTY the second time.

If waybar is not loading, the first thing that you should try is to reboot your system and try again.

You can open a terminal with SUPER+Return and enter wlogout.

If it's still not working, please try to uninstall xdg-desktop-portal-gtk.

```shell
sudo pacman -R xdg-desktop-portal-gtk
```

Reboot your system again.

Waybar should be working now, but you will lose dark mode in libadwaita apps.

Then try to install it again with:

```shell
sudo pacman -S xdg-desktop-portal-gtk
```

Please, also make sure that xdg-desktop-portal-gnome is not installed in parallel to xdg-desktop-portal-gtk. Please, try to remove the package if it is.

If the issue is still present, please uninstall the package again. If dark mode is required, install dolphin, qt6ct and enable breeze and darker colors to get a filemanager in dark mode.

### No Dark Theme on GTK4 Apps

The package xdg-desktop-portal-gtk is not installed.

You can install it with:

```shell
sudo pacman -S xdg-desktop-portal-gtk
```

And reboot your system.

## Inspirations

The following projects have inspired me:

- https://github.com/JaKooLit/Hyprland-Dots
- https://github.com/prasanthrangan/hyprdots
- https://github.com/sudo-harun/dotfiles
- https://github.com/dianaw353/hyprland-configuration-rootfs
- https://github.com/mylinuxforwork/dotfiles

and many more...
