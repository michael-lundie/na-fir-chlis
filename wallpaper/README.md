# Wallpaper

Original artwork for the Na Fir-Chlis theme – my painting **"Escape"**, painted in 2023 and edited and recoloured to sit inside the Nord palette.
It ships in four variations, each grounded on a different Polar Night shade:

| File                          | Ground | Hex       |
|-------------------------------|--------|-----------|
| `nord-crewman-35-nord0.png`   | nord0  | `#2E3440` |
| `nord-crewman-35-nord1.png`   | nord1  | `#3B4252` |
| `nord-crewman-35-nord2.png`   | nord2  | `#434C5E` |
| `nord-crewman-35-nord3.png`   | nord3  | `#4C566A` |

`nord0` is the shipped default – it matches the desktop and terminal background,
so the gaps and borders melt into the art.
i3 applies it on start automatically, resolved relative to wherever the repo was cloned, so a fresh clone looks complete with no path to edit.

To use one of the lighter grounds – or any other wallpaper – run `feh --bg-fill /path/to/other.png`.
That writes `~/.fehbg`, which takes precedence over the shipped default.
Alternatively, set `DOTFILES_WALLPAPER` to point the start-up wallpaper (and lock screen) at a specific file.

The files are deliberately optimised to ~350–400 KB so they stay light in git history.
Each carries a small `lundie.io` wordmark.

## Source

Painted by Michael Lundie – [lundie.io](https://lundie.io).
More Nord-themed paintings to come.

## Licence

The artwork in this directory – the *"Escape"* paintings – is **not** covered by the repo's MIT licence.
It is © Michael Lundie, licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/): use and share it with attribution, but **no commercial use** and **no derivatives** (please don't redistribute modified or recoloured versions).
The MIT `LICENSE` at the repo root covers the code only.