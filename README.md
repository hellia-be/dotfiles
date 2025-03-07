# Dotfiles for QTILE

Configuration for Arch Linux based distributions. This package includes an installation script to install and set up the required components.

## Main Packages

- Terminal: alacritty
- Editor: vim
- Prompt: oh-my-posh
- Wallpaper: wal
- Icons: Font Awesome and JetBrans Mono
- Launch Menus: Rofi
- Color Theme: pywal
- Browser: Zen Browser
- Filemanager: thunar
- Screenshots: flameshot
- Idle Manager: xidle
- Screenlock: betterlockscreen
- GTK Theme Manager: lxappearance
- QT6 Theme Manager: qt6ct

## Installation

The installation works on Arch Linux distributions.

> IMPORTANT: Please make sure that all packages on your system are updated before running the installation script.

> PLEASE NOTE: Every Linux distribution, setup, and personal configuration can be different. Therefore, I can't guarantee that these dotfiles will work everywhere. You install at your own risk.

```shell
bash <(curl -s https://raw.githubusercontent.com/hellia-be/dotfiles/main/setup_part1.sh)
```

Please rebuild all packages to ensure that you get the latest commit.

Wait for the system to reboot.
After logging in, you can do `MOD` + `T` and select the Natura theme.
Also do `MOD` + `ENTER` and type `chsh`
Here you need to select `/usr/bin/bash`

Once done run:
```shell
bash <(curl -s https://raw.githubusercontent.com/hellia-be/dotfiles/main/setup_part2.sh)
```

## Troubleshooting

### Issues with SDDM Sequoia Theme

If you notice an error with the Sequoia theme, you can uninstall the theme with

```shell
sudo rm -rf /usr/share/sddm/themes/sequoia
```

### No Dark Theme on GTK4 Apps

The package xdg-desktop-portal-gtk is not installed.

You can install it with:

```shell
sudo pacman -S xdg-desktop-portal-gtk
```

And reboot your system.

## Inspirations

The following projects have inspired me:

- https://github.com/Darkkal44/Cozytile
- https://github.com/mylinuxforwork/dotfiles

and many more...
