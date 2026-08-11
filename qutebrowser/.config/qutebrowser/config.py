# qutebrowser configuration – Nord theme.
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
#
# qutebrowser writes its own settings file (autoconfig.yml) into this
# directory whenever you change something from the GUI. We ignore it here so
# this file stays the single source of truth (and the repo stays clean).
config.load_autoconfig(False)

# --- Nord palette --------------------------------------------------------
# https://www.nordtheme.com/docs/colors-and-palettes
nord = {
    # Polar Night
    "nord0":  "#2e3440",
    "nord1":  "#3b4252",
    "nord2":  "#434c5e",
    "nord3":  "#4c566a",
    # Snow Storm
    "nord4":  "#d8dee9",
    "nord5":  "#e5e9f0",
    "nord6":  "#eceff4",
    # Frost
    "nord7":  "#8fbcbb",
    "nord8":  "#88c0d0",
    "nord9":  "#81a1c1",
    "nord10": "#5e81ac",
    # Aurora
    "nord11": "#bf616a",  # red
    "nord12": "#d08770",  # orange
    "nord13": "#ebcb8b",  # yellow
    "nord14": "#a3be8c",  # green
    "nord15": "#b48ead",  # purple
}

c = c  # noqa: F821 (provided by qutebrowser at load time)

# --- Completion ----------------------------------------------------------
c.colors.completion.fg = nord["nord4"]
c.colors.completion.odd.bg = nord["nord1"]
c.colors.completion.even.bg = nord["nord0"]
c.colors.completion.category.fg = nord["nord8"]
c.colors.completion.category.bg = nord["nord0"]
c.colors.completion.category.border.top = nord["nord0"]
c.colors.completion.category.border.bottom = nord["nord0"]
c.colors.completion.item.selected.fg = nord["nord0"]
c.colors.completion.item.selected.bg = nord["nord8"]
c.colors.completion.item.selected.border.top = nord["nord8"]
c.colors.completion.item.selected.border.bottom = nord["nord8"]
c.colors.completion.item.selected.match.fg = nord["nord0"]
c.colors.completion.match.fg = nord["nord13"]
c.colors.completion.scrollbar.fg = nord["nord4"]
c.colors.completion.scrollbar.bg = nord["nord0"]

# --- Downloads -----------------------------------------------------------
c.colors.downloads.bar.bg = nord["nord0"]
c.colors.downloads.start.fg = nord["nord0"]
c.colors.downloads.start.bg = nord["nord8"]
c.colors.downloads.stop.fg = nord["nord0"]
c.colors.downloads.stop.bg = nord["nord14"]
c.colors.downloads.error.fg = nord["nord11"]

# --- Hints ---------------------------------------------------------------
c.colors.hints.fg = nord["nord0"]
c.colors.hints.bg = nord["nord13"]
c.colors.hints.match.fg = nord["nord11"]
c.hints.border = "1px solid " + nord["nord3"]

# --- Keyhint -------------------------------------------------------------
c.colors.keyhint.fg = nord["nord4"]
c.colors.keyhint.suffix.fg = nord["nord13"]
c.colors.keyhint.bg = nord["nord0"]

# --- Messages ------------------------------------------------------------
c.colors.messages.error.fg = nord["nord6"]
c.colors.messages.error.bg = nord["nord11"]
c.colors.messages.error.border = nord["nord11"]
c.colors.messages.warning.fg = nord["nord6"]
c.colors.messages.warning.bg = nord["nord12"]
c.colors.messages.warning.border = nord["nord12"]
c.colors.messages.info.fg = nord["nord4"]
c.colors.messages.info.bg = nord["nord0"]
c.colors.messages.info.border = nord["nord0"]

# --- Prompts -------------------------------------------------------------
c.colors.prompts.fg = nord["nord4"]
c.colors.prompts.bg = nord["nord1"]
c.colors.prompts.border = "1px solid " + nord["nord0"]
c.colors.prompts.selected.bg = nord["nord2"]
c.colors.prompts.selected.fg = nord["nord4"]

# --- Statusbar -----------------------------------------------------------
c.colors.statusbar.normal.fg = nord["nord4"]
c.colors.statusbar.normal.bg = nord["nord0"]
c.colors.statusbar.insert.fg = nord["nord0"]
c.colors.statusbar.insert.bg = nord["nord14"]
c.colors.statusbar.passthrough.fg = nord["nord0"]
c.colors.statusbar.passthrough.bg = nord["nord8"]
c.colors.statusbar.private.fg = nord["nord6"]
c.colors.statusbar.private.bg = nord["nord3"]
c.colors.statusbar.command.fg = nord["nord4"]
c.colors.statusbar.command.bg = nord["nord0"]
c.colors.statusbar.command.private.fg = nord["nord4"]
c.colors.statusbar.command.private.bg = nord["nord3"]
c.colors.statusbar.caret.fg = nord["nord6"]
c.colors.statusbar.caret.bg = nord["nord15"]
c.colors.statusbar.caret.selection.fg = nord["nord6"]
c.colors.statusbar.caret.selection.bg = nord["nord10"]
c.colors.statusbar.progress.bg = nord["nord8"]
c.colors.statusbar.url.fg = nord["nord4"]
c.colors.statusbar.url.error.fg = nord["nord11"]
c.colors.statusbar.url.hover.fg = nord["nord8"]
c.colors.statusbar.url.success.http.fg = nord["nord14"]
c.colors.statusbar.url.success.https.fg = nord["nord14"]
c.colors.statusbar.url.warn.fg = nord["nord13"]

# --- Tabs ----------------------------------------------------------------
c.colors.tabs.bar.bg = nord["nord0"]
c.colors.tabs.indicator.start = nord["nord10"]
c.colors.tabs.indicator.stop = nord["nord8"]
c.colors.tabs.indicator.error = nord["nord11"]
c.colors.tabs.odd.fg = nord["nord4"]
c.colors.tabs.odd.bg = nord["nord1"]
c.colors.tabs.even.fg = nord["nord4"]
c.colors.tabs.even.bg = nord["nord2"]
c.colors.tabs.selected.odd.fg = nord["nord0"]
c.colors.tabs.selected.odd.bg = nord["nord8"]
c.colors.tabs.selected.even.fg = nord["nord0"]
c.colors.tabs.selected.even.bg = nord["nord8"]
c.colors.tabs.pinned.even.bg = nord["nord14"]
c.colors.tabs.pinned.even.fg = nord["nord6"]
c.colors.tabs.pinned.odd.bg = nord["nord14"]
c.colors.tabs.pinned.odd.fg = nord["nord6"]
c.colors.tabs.pinned.selected.even.bg = nord["nord8"]
c.colors.tabs.pinned.selected.even.fg = nord["nord0"]
c.colors.tabs.pinned.selected.odd.bg = nord["nord8"]
c.colors.tabs.pinned.selected.odd.fg = nord["nord0"]

# --- Context menu --------------------------------------------------------
c.colors.contextmenu.menu.bg = nord["nord0"]
c.colors.contextmenu.menu.fg = nord["nord4"]
c.colors.contextmenu.selected.bg = nord["nord8"]
c.colors.contextmenu.selected.fg = nord["nord0"]

# --- Behaviour / appearance ---------------------------------------------
c.fonts.default_family = "FiraCode Nerd Font"
c.fonts.default_size = "10pt"
c.tabs.position = "top"
c.scrolling.smooth = True
c.colors.webpage.preferred_color_scheme = "dark"

# --- Keybindings ---------------------------------------------------------
# F11 toggles fullscreen so the i3 web-app launchers can fullscreen the new
# window the same way they do for other browsers.
config.bind("<F11>", "fullscreen")

# --- Machine-local overrides --------------------------------------------
# Sources `local.py` from the config directory if it exists – per-machine
# settings (a different start page, a machine-specific zoom) that shouldn't be
# shared across machines. Untracked, and a no-op when the file is absent.
import os.path  # noqa: E402 (qutebrowser runs this file top-to-bottom)

if os.path.exists(os.path.join(str(config.configdir), "local.py")):
    config.source("local.py")
