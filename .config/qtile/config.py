from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match, hook, Screen
from libqtile.lazy import lazy
from time import sleep
import socket
import os
import subprocess

mod = "mod4"
terminal = "alacritty"

# █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀
# █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█

keys = [
    # Window Management
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key([mod, "control"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "control"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "control"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "control"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "shift"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "shift"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "shift"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "f", lazy.window.toggle_fullscreen()),
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "comma", lazy.window.prev_screen(), desc="Move window to previous screen"),
    Key([mod, "shift"], "period", lazy.window.next_screen(), desc="Move window to next screen"),
    Key([mod], "comma", lazy.prev_screen(), desc="Focus previous screen"),
    Key([mod], "period", lazy.next_screen(), desc="Focus next screen"),

    # Screen Management
    # For first screen (screen index 0)
    Key([mod, "mod1"], "1", lazy.group["1"].toscreen(0)),
    Key([mod, "mod1"], "2", lazy.group["2"].toscreen(0)),
    Key([mod, "mod1"], "3", lazy.group["3"].toscreen(0)),
    # For second screen (screen index 1)
    Key([mod, "mod1"], "q", lazy.group["1"].toscreen(1)),
    Key([mod, "mod1"], "w", lazy.group["2"].toscreen(1)),
    Key([mod, "mod1"], "e", lazy.group["3"].toscreen(1)),

    # Application Launching
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "r", lazy.spawn("sh -c ~/.config/rofi/scripts/launcher"), desc="Spawn a command using a prompt widget"),
    Key([mod], "e", lazy.spawn("thunar"), desc='file manager'),
    Key([mod], "s", lazy.spawn("flameshot gui"), desc='Screenshot'),
    Key([mod, "shift"], "l", lazy.spawn("/usr/bin/betterlockscreen -l"), desc="Launch lockscreen"),
    Key([mod, "shift"], "r", lazy.spawn("sh -c ~/.config/rofi/scripts/power"), desc="Power menu"),
    Key([mod, "shift"], "p", lazy.spawn("sh -c ~/.config/qtile/battery-menu.sh"), desc="Power profile menu"),
    Key([], "Print", lazy.spawn("flameshot launcher"), desc="Screenshot"),

    # Qtile Control
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod], "p", lazy.spawn("sh -c ~/.config/rofi/scripts/power"), desc='powermenu'),

    # Media Controls
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume 0 +5%"), desc='Volume Up'),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume 0 -5%"), desc='volume down'),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc='Volume Mute'),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc='playerctl'),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc='playerctl'),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc='playerctl'),

    # Brightness Controls
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s 10%+"), desc='brightness UP'),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 10%-"), desc='brightness Down'),
]

# █▀▀ █▀█ █▀█ █░█ █▀█ █▀
# █▄█ █▀▄ █▄█ █▄█ █▀▀ ▄█

groups = [Group(f"{i+1}", label="") for i in range(3)]

for i in groups:
    keys.extend(
            [
                Key([mod], i.name, lazy.group[i.name].toscreen(), desc="Switch to group {}".format(i.name),),
                Key([mod, "control", "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc="Switch to & move focused window to group {}".format(i.name),),
                Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=False), desc="Move window to group {} without switching".format(i.name),),
                ]
            )

# L A Y O U T S
lay_config = {
    "border_width": 0,
    "margin": 9,
    "border_focus": "3b4252",
    "border_normal": "3b4252",
    "font": "FiraCode Nerd Font",
    "grow_amount": 2,
}

layouts = [
    layout.Bsp(**lay_config, fair=False, border_on_single=True),
    layout.Max(**lay_config),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=13,
    padding=3,
)

extension_defaults = [ widget_defaults.copy()
        ]

def power():
    qtile.spawn("sh -c ~/.config/rofi/scripts/power")

def bt():
    qtile.spawn("blueman-manager")

def net():
    qtile.spawn("alacritty -e nmtui")

def cal():
    qtile.spawn("google-chrome-stable https://calendar.google.com/calendar")

def sound():
    qtile.spawn("pavucontrol")

myhostname = socket.gethostname()

# █▄▄ ▄▀█ █▀█
# █▄█ █▀█ █▀▄

screens = [
    *([Screen (),] if myhostname == 'arch-desktop' else []),
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=15,
                    background='#0F1212',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/launch_Icon.png',
                    margin=2,
                    background='#0F1212',
                    mouse_callbacks={"Button1": power},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/6.png',
                ),

                widget.GroupBox(
                    font="JetBrainsMono Nerd Font",
                    fontsize=24,
                    borderwidth=3,
                    highlight_method='block',
                    active='#607767',
                    block_highlight_text_color="#607767",
                    highlight_color='#202222',
                    inactive='#0F1212',
                    foreground='#4B427E',
                    background='#202222',
                    this_current_screen_border='#202222',
                    this_screen_border='#202222',
                    other_current_screen_border='#202222',
                    other_screen_border='#202222',
                    urgent_border='#202222',
                    rounded=True,
                    disable_drag=True,
                ),

                widget.Spacer(
                    length=8,
                    background='#202222',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/1.png',
                ),

                widget.Spacer(
                    background='#202222',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.Bluetooth(
                    default_show_battery=True,
                    background='#202222',
                    foreground='#607767',
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    default_text="{connected_devices}",
                    mouse_callbacks={"Button1": bt},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background="#202222",
                    foreground='#607767',
                    mouse_callbacks={"Button1": net},
                ),

                widget.GenPollText(
                    func=lambda: subprocess.check_output(["/usr/bin/python", os.path.expanduser("~/.config/qtile/network_status.py")]).decode("utf-8").strip(),
                    update_interval=5,
                    foreground="#607767",
                    background="#202222",
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    mouse_callbacks={"Button1": net},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background='#202222',
                    foreground='#607767',
                ),

                widget.Battery(
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    background='#202222',
                    foreground='#607767',
                    format='{percent:2.0%}',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.Systray(
                    background='#202222',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.Spacer(
                    length=8,
                    background='#202222',
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background='#202222',
                    foreground='#607767',
                ),

                widget.Volume(
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    background='#202222',
                    foreground='#607767',
                    mouse_callbacks={"Button1": sound},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/5.png',
                    background='#202222',
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background='#0F1212',
                    foreground='#607767',
                    mouse_callbacks={"Button1": cal},
                ),

                widget.Clock(
                    format='%H:%M | %d %b %Y',
                    background='#0F1212',
                    foreground='#607767',
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    mouse_callbacks={"Button1": cal},

                ),

                widget.Spacer(
                    length=18,
                    background='#0F1212',
                ),
            ],
            30,
            border_color='#0F1212',
            border_width=[0,0,0,0],
            margin=[9,9,0,9],
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus='#1F1D2E',
    border_normal='#1F1D2E',
    border_width=0,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="steam"),
        Match(title="Battle.net"),
    ]
)

@hook.subscribe.startup_once
def autostart():
    subprocess.call([os.path.expanduser('~/.config/qtile/autostart_once.sh')])

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

# E O F 
