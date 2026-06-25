# Na Fir-Chlis – a Nord i3wm theme · lundie.io

# IBus (Japanese input) environment – only set when ibus is installed, so the
# same .xinitrc is a clean no-op on machines without Japanese support.
if command -v ibus-daemon >/dev/null 2>&1; then
    export GTK_IM_MODULE=ibus
    export QT_IM_MODULE=ibus
    export XMODIFIERS=@im=ibus
fi

# Nord theme for every glamour-based markdown renderer (glow, gh, glab).
# One stylesheet, one source of truth – see glow/.config/glow/nord.json.
export GLAMOUR_STYLE="$HOME/.config/glow/nord.json"

# Import X display variables into the user systemd/dbus environment so
# xdg-desktop-portal-gtk can spawn file chooser dialogs under i3.
if [ -f /etc/X11/xinit/xinitrc.d/50-systemd-user.sh ]; then
    . /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
fi

exec i3
