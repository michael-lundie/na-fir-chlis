# Wallpaper

Original artwork for the Na Fir-Chlis theme. Two paintings ship here, both recoloured to sit inside the Nord palette, and each carrying a small `lundie.io` wordmark.

Files are named `<painting>-<variant>-<resolution>.png`. The variant axis differs by work – "Escape" varies by the Polar Night ground it sits on, "Earthrise" by palette depth – but the field order is the same, so the files group by painting and sort predictably.

## "Escape" (2023)

My painting **"Escape"**, edited and recoloured for Nord.
It ships in four variations, each grounded on a different Polar Night shade:

| File                       | Ground | Hex       |
|----------------------------|--------|-----------|
| `escape-nord0-1440p.png`   | nord0  | `#2E3440` |
| `escape-nord1-1440p.png`   | nord1  | `#3B4252` |
| `escape-nord2-1440p.png`   | nord2  | `#434C5E` |
| `escape-nord3-1440p.png`   | nord3  | `#4C566A` |

`nord0` is the shipped default – it matches the desktop and terminal background,
so the gaps and borders melt into the art.
i3 applies it on start automatically, resolved relative to wherever the repo was cloned, so a fresh clone looks complete with no path to edit.

All four are 2560×1440 and flat-shaded, so they downscale cleanly to smaller screens. That tolerance is why "Escape" remains the shipped default rather than "Earthrise".

## "Earthrise"

Unlike "Escape", it is a **full-bleed** composition – the art runs edge to edge, with no Polar Night ground behind it – so it varies by palette depth rather than by ground shade.

It ships as two cuts, each **rendered natively at two resolutions**:

| File                        | Palette    | Resolution  | Size   |
|-----------------------------|------------|-------------|--------|
| `earthrise-x08-1080p.png`   | 8 colours  | 1920×1080   | 73 KB  |
| `earthrise-x08-1440p.png`   | 8 colours  | 2560×1440   | 182 KB |
| `earthrise-x16-1080p.png`   | 16 colours | 1920×1080   | 87 KB  |
| `earthrise-x16-1440p.png`   | 16 colours | 2560×1440   | 213 KB |

The `x8` cut is restricted to black, `nord0`–`nord2` and four of the Snow Storm / Frost shades: a coarser, more visible dither. The `x16` cut opens up `nord3`, the Frost blues and small hits of the Aurora accents, holding a smoother tonal falloff in the sky.

**Pick the cut that matches your screen, and don't let it scale.**
The tone in these is carried by an ordered dither – a per-pixel pattern, not a gradient. Each resolution was rendered separately at its native size; neither is a resample of the other. Any rescaling blends adjacent dither cells and the pattern collapses into mush, so a 1080p cut stretched onto a 1440p display loses the very texture it exists for.

On a 1920×1080 or 2560×1440 screen, `feh --bg-fill` maps the matching file 1:1 and the dither survives intact. On any other resolution, prefer:

```bash
feh --bg-center /path/to/earthrise-x16-1440p.png
```

`--bg-center` places the image at native size without resampling, letting the surrounding desktop show through rather than smearing the pattern. Because the art is grounded in black and `nord0`, the join is close to invisible.

## Choosing one

To use any of these – or any other image – on a given machine:

```bash
feh --bg-fill /path/to/other.png
```

That writes `~/.fehbg`, which takes precedence over the shipped default.
Alternatively, set `DOTFILES_WALLPAPER` to point the start-up wallpaper (and lock screen) at a specific file.

Every file here is kept small so it stays light in git history – the "Escape" cuts land at ~350–400 KB, the "Earthrise" cuts well under that thanks to their reduced palettes.

## Source

Painted by Michael Lundie – [lundie.io](https://lundie.io).
More Nord-themed paintings to come.

## Licence

The artwork in this directory – the *"Escape"* and *"Earthrise"* paintings – is **not** covered by the repo's MIT licence.
It is © Michael Lundie, licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/): use and share it with attribution, but **no commercial use** and **no derivatives** (please don't redistribute modified or recoloured versions).
The MIT `LICENSE` at the repo root covers the code only.
