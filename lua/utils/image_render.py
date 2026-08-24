#!/usr/bin/env python3
import sys
import os
import json

def format_size(num_bytes):
    if num_bytes < 1024:
        return f"{num_bytes} B"
    elif num_bytes < 1024 * 1024:
        return f"{num_bytes / 1024:.1f} KB"
    else:
        return f"{num_bytes / (1024 * 1024):.2f} MB"

def hex_to_rgb(hex_str, default=(30, 30, 30)):
    if not hex_str:
        return default
    hex_str = hex_str.lstrip('#')
    if len(hex_str) == 6:
        return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))
    return default

def render_image(path, max_cols=60, max_rows=30, zoom=1.0, bg_hex=""):
    try:
        from PIL import Image, ImageOps
    except ImportError:
        return {"error": "Pillow (PIL) is not installed. Please run: pip3 install pillow"}

    if not os.path.exists(path):
        return {"error": f"File not found: {path}"}

    try:
        im = Image.open(path)
        # Handle orientation if present in EXIF
        try:
            im = ImageOps.exif_transpose(im)
        except Exception:
            pass

        orig_w, orig_h = im.size
        fmt = (im.format or os.path.splitext(path)[1].replace(".", "").upper())
        file_size = os.path.getsize(path)
        size_str = format_size(file_size)

        if orig_w <= 0 or orig_h <= 0:
            return {"error": "Invalid image dimensions"}

        aspect = orig_w / float(orig_h)

        # In a standard terminal font, a character cell is approx twice as tall as it is wide (1:2).
        # A half-block character ('▀') divides 1 cell into 2 vertical subpixels (top and bottom).
        # Therefore, 1 terminal column x 0.5 terminal row represents a square 1:1 subpixel.
        # In terms of terminal cell dimensions:
        # cell_aspect = aspect * 2 (because 1 row has 2 vertical subpixels)
        cell_aspect = aspect * 2.0

        # Fit within max_cols and max_rows proportionally
        base_cols = max_cols
        base_rows = int(round(base_cols / cell_aspect))
        if base_rows > max_rows:
            base_rows = max_rows
            base_cols = int(round(base_rows * cell_aspect))

        # Apply zoom multiplier
        cols = max(4, int(round(base_cols * zoom)))
        rows = max(2, int(round(base_rows * zoom)))

        # Subpixel resolution for rendering
        pix_w = cols
        pix_h = rows * 2

        im_rgba = im.convert("RGBA")
        im_resized = im_rgba.resize((pix_w, pix_h), Image.Resampling.LANCZOS)
        px = im_resized.load()

        bg_rgb = hex_to_rgb(bg_hex, default=(30, 30, 30))
        def_r, def_g, def_b = bg_rgb

        lines = []
        for r in range(rows):
            line_parts = []
            y_top = r * 2
            y_bot = r * 2 + 1
            last_fg = None
            last_bg = None

            for c in range(cols):
                top = px[c, y_top]
                bot = px[c, y_bot] if y_bot < pix_h else (0, 0, 0, 0)

                top_a = top[3] / 255.0
                bot_a = bot[3] / 255.0

                top_r = int(top[0] * top_a + def_r * (1.0 - top_a))
                top_g = int(top[1] * top_a + def_g * (1.0 - top_a))
                top_b = int(top[2] * top_a + def_b * (1.0 - top_a))

                bot_r = int(bot[0] * bot_a + def_r * (1.0 - bot_a))
                bot_g = int(bot[1] * bot_a + def_g * (1.0 - bot_a))
                bot_b = int(bot[2] * bot_a + def_b * (1.0 - bot_a))

                fg_key = (top_r, top_g, top_b)
                bg_key = (bot_r, bot_g, bot_b)

                if fg_key != last_fg or bg_key != last_bg:
                    line_parts.append(f"\033[38;2;{top_r};{top_g};{top_b}m\033[48;2;{bot_r};{bot_g};{bot_b}m")
                    last_fg = fg_key
                    last_bg = bg_key

                line_parts.append("▀")

            line_parts.append("\033[0m")
            lines.append("".join(line_parts))

        return {
            "orig_w": orig_w,
            "orig_h": orig_h,
            "format": fmt,
            "size_str": size_str,
            "cols": cols,
            "rows": rows,
            "lines": lines
        }

    except Exception as e:
        return {"error": str(e)}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: image_render.py <image_path> [max_cols] [max_rows] [zoom] [bg_hex]"}))
        sys.exit(1)

    path = sys.argv[1]
    max_cols = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    max_rows = int(sys.argv[3]) if len(sys.argv) > 3 else 30
    zoom = float(sys.argv[4]) if len(sys.argv) > 4 else 1.0
    bg_hex = sys.argv[5] if len(sys.argv) > 5 else ""

    result = render_image(path, max_cols, max_rows, zoom, bg_hex)
    print(json.dumps(result))

if __name__ == "__main__":
    main()
