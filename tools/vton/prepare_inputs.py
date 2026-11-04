"""Prepare PoC inputs from Kabinsiz OWNED_ORIGINAL assets (ADR-017 L1).

- avatar: crop the dressed 3D figure out of a simulator screenshot and pad it to 2:3 on a neutral wall
- garments: composite the Blender garment thumbnails (transparent PNG) onto white, as a flat-lay
"""
import argparse
from pathlib import Path

from PIL import Image


def pad_to(img, ratio_w, ratio_h, fill):
    w, h = img.size
    tw = max(w, int(h * ratio_w / ratio_h))
    th = max(h, int(tw * ratio_h / ratio_w))
    canvas = Image.new("RGB", (tw, th), fill)
    canvas.paste(img, ((tw - w) // 2, (th - h) // 2))
    return canvas


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--screenshot", required=True)
    ap.add_argument("--box", default="140,185,370,700", help="left,top,right,bottom of the figure")
    ap.add_argument("--garments", nargs="+", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    box = tuple(int(v) for v in a.box.split(","))
    fig = Image.open(a.screenshot).convert("RGB").crop(box)
    fig = fig.resize((fig.width * 3, fig.height * 3), Image.LANCZOS)
    pad_to(fig, 2, 3, (226, 218, 206)).save(out / "avatar.png")
    for g in a.garments:
        src = Image.open(g).convert("RGBA")
        bg = Image.new("RGBA", src.size, (255, 255, 255, 255))
        flat = Image.alpha_composite(bg, src).convert("RGB")
        pad_to(flat, 2, 3, (255, 255, 255)).save(out / (Path(g).stem + "-flatlay.png"))
    print(sorted(p.name for p in out.iterdir()))


if __name__ == "__main__":
    main()
