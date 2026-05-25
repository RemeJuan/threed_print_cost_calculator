#!/usr/bin/env python3
"""
Generate localized store screenshots with template-driven text overlays.

Renders heading text at per-asset coordinates over fixed base images.
Base images must be at exact output resolution — no resizing performed.

Usage:
    python3 scripts/generate_screenshots.py [options]

Options:
    --base-dir DIR       Base image directory (default: fastlane/screenshots/base)
    --layout FILE        Layout metadata YAML (default: fastlane/screenshots/layout.yaml)
    --copy-dir DIR       Copy YAML directory (default: fastlane/screenshots/copy)
    --output-dir DIR     Output directory (default: fastlane/screenshots/output)
    --formats LIST       Comma-separated platforms (default: ios,android)
    --locale LOCALE      Generate only this locale
    --font PATH          Heading font path (default: assets/fonts/inter/Inter-Bold.ttf)
    --skip-missing       Skip missing base images instead of failing
"""

import argparse
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("ERROR: Pillow required. Install: pip install Pillow")
    sys.exit(1)

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML required. Install: pip install PyYAML")
    sys.exit(1)

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

DEFAULT_BASE_DIR = REPO_ROOT / "fastlane" / "screenshots" / "base"
DEFAULT_LAYOUT = REPO_ROOT / "fastlane" / "screenshots" / "layout.yaml"
DEFAULT_COPY_DIR = REPO_ROOT / "fastlane" / "screenshots" / "copy"
DEFAULT_OUTPUT_DIR = REPO_ROOT / "fastlane" / "screenshots" / "output"
DEFAULT_FONT = REPO_ROOT / "assets" / "fonts" / "inter" / "Inter-Bold.ttf"

COLORS = {
    "primary": (255, 255, 255),
    "accent": (84, 153, 254),
}

FORMAT_BASE_SUBDIRS = {
    "ios": "ios",
    "android": "android",
}


def _resolve_font(path_spec, size):
    path = Path(path_spec) if path_spec else None
    if path and path.exists():
        try:
            return ImageFont.truetype(str(path), round(size))
        except Exception:
            pass
    for candidate in [
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Helvetica.ttc",
    ]:
        if os.path.exists(candidate):
            return ImageFont.truetype(candidate, round(size))
    return ImageFont.load_default()


def _load_yaml(path):
    try:
        with open(path) as f:
            data = yaml.safe_load(f)
        if data is None:
            print(f"ERROR: {path} is empty")
            sys.exit(1)
        return data
    except yaml.YAMLError as e:
        print(f"ERROR: Invalid YAML in {path}: {e}")
        sys.exit(1)


def _measure_text(draw, text, font):
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def _tokenize_segment(text, style):
    import re

    return [
        {"text": token, "style": style, "is_space": token.isspace()}
        for token in re.findall(r"\s+|\S+", text)
        if token
    ]


def _draw_segments(draw, segments, x, y, font, colors):
    for seg in segments:
        text = seg.get("text", "")
        style = seg.get("style", "primary")
        color = colors.get(style, colors["primary"])
        draw.text((x, y), text, fill=color, font=font)
        w, _ = _measure_text(draw, text, font)
        x += w


def _validate_layout(data, path):
    if "formats" not in data:
        print(f"ERROR: {path} missing 'formats' key")
        sys.exit(1)
    for fmt, fmt_data in data["formats"].items():
        if "assets" not in fmt_data:
            print(f"ERROR: {path}: format '{fmt}' missing 'assets'")
            sys.exit(1)
        for aid, cfg in fmt_data["assets"].items():
            if "source" not in cfg:
                print(f"ERROR: {path}: format '{fmt}' asset '{aid}' missing 'source'")
                sys.exit(1)
            for k in (
                "x",
                "y",
                "max_width",
                "max_height",
                "font_size",
                "min_font_size",
                "line_height",
                "max_lines",
                "align",
                "wrap",
                "fit_mode",
            ):
                if k not in cfg:
                    print(f"ERROR: {path}: format '{fmt}' asset '{aid}' missing '{k}'")
                    sys.exit(1)
            if cfg["wrap"] is not True:
                print(f"ERROR: {path}: format '{fmt}' asset '{aid}' wrap must be true")
                sys.exit(1)
            if cfg["fit_mode"] != "shrink_to_fit":
                print(f"ERROR: {path}: format '{fmt}' asset '{aid}' fit_mode must be shrink_to_fit")
                sys.exit(1)


def _validate_copy(data, path, fmt_assets):
    if not data or "screenshots" not in data:
        print(f"ERROR: {path} missing 'screenshots' key")
        sys.exit(1)
    for i, ss in enumerate(data["screenshots"]):
        if "asset" not in ss:
            print(f"ERROR: {path}: screenshot #{i + 1} missing 'asset' id")
            sys.exit(1)
        aid = ss["asset"]
        if aid not in fmt_assets:
            print(f"ERROR: {path}: asset '{aid}' not found in format layout")
            sys.exit(1)
        if "heading" not in ss:
            print(f"ERROR: {path}: asset '{aid}' missing 'heading'")
            sys.exit(1)
        heading = ss["heading"]
        if not isinstance(heading, list) or len(heading) == 0:
            print(f"ERROR: {path}: asset '{aid}' heading must be a non-empty list")
            sys.exit(1)
        for j, entry in enumerate(heading):
            if isinstance(entry, dict) and "line" in entry:
                line_segs = entry["line"]
                if not isinstance(line_segs, list) or len(line_segs) == 0:
                    print(
                        f"ERROR: {path}: asset '{aid}' heading line #{j + 1} "
                        f"must be a non-empty list"
                    )
                    sys.exit(1)
                for k, seg in enumerate(line_segs):
                    _validate_segment(path, aid, seg, j, k)
            else:
                _validate_segment(path, aid, entry, j, None)


def _validate_segment(path, aid, seg, line_idx, seg_idx):
    label = f"segment #{seg_idx + 1}" if seg_idx is not None else "entry"
    pos = f"heading line #{line_idx + 1} {label}"
    if "text" not in seg or "style" not in seg:
        print(f"ERROR: {path}: asset '{aid}' {pos} missing 'text' or 'style'")
        sys.exit(1)
    if seg["style"] not in COLORS:
        print(f"ERROR: {path}: asset '{aid}' {pos} unknown style '{seg['style']}'")
        sys.exit(1)


def _resolve_formats(raw):
    PLATFORM_PRESETS = {
        "ios": ["ios"],
        "android": ["android"],
    }
    out = []
    for f in (x.strip() for x in raw.split(",")):
        if f in PLATFORM_PRESETS:
            out.extend(PLATFORM_PRESETS[f])
        elif f == "all":
            for preset in PLATFORM_PRESETS.values():
                out.extend(preset)
        else:
            out.append(f)
    return out


def _format_base_subdir(fmt):
    subdir = FORMAT_BASE_SUBDIRS.get(fmt)
    if subdir:
        return subdir
    print(f"ERROR: No base subdir mapped for format '{fmt}'")
    sys.exit(1)


def _line_segments(entry):
    if isinstance(entry, dict) and "line" in entry:
        return entry["line"]
    return [entry]


def _paragraph_tokens(entry):
    tokens = []
    for seg in _line_segments(entry):
        tokens.extend(_tokenize_segment(seg.get("text", ""), seg.get("style", "primary")))
    return tokens


def _measure_segments(draw, segments, font):
    total_w = 0
    max_h = 0
    for seg in segments:
        w, h = _measure_text(draw, seg.get("text", ""), font)
        total_w += w
        max_h = max(max_h, h)
    return total_w, max_h


def _wrap_paragraph(draw, tokens, font, max_width):
    lines = []
    current = []
    current_width = 0

    for token in tokens:
        text = token["text"]
        is_space = token["is_space"]
        if is_space and not current:
            continue

        token_width, _ = _measure_text(draw, text, font)
        if current and current_width + token_width > max_width:
            lines.append(current)
            current = []
            current_width = 0
            if is_space:
                continue

        if not current and is_space:
            continue

        current.append({"text": text, "style": token["style"]})
        current_width += token_width

    if current:
        lines.append(current)

    return lines


def _measure_line(draw, line, font):
    total_w = 0
    max_h = 0
    for token in line:
        w, h = _measure_text(draw, token.get("text", ""), font)
        total_w += w
        max_h = max(max_h, h)
    return total_w, max_h


def _render_heading(draw, heading, cfg, font_path, colors):
    x = cfg["x"]
    y = cfg["y"]
    max_width = cfg["max_width"]
    max_height = cfg["max_height"]
    base_size = cfg["font_size"]
    min_size = cfg.get("min_font_size", max(10, base_size // 2))
    absolute_min_size = cfg.get("absolute_min_font_size", 36)
    line_height = cfg["line_height"]
    max_lines = cfg["max_lines"]
    align = cfg.get("align", "left")
    fit_mode = cfg.get("fit_mode", "shrink_to_fit")

    paragraphs = []
    if any(isinstance(entry, dict) and "line" in entry for entry in heading):
        for entry in heading:
            paragraphs.append((
                _paragraph_tokens(entry),
                {k: v for k, v in entry.items() if k != "line"},
            ))
    else:
        paragraphs.append((_paragraph_tokens({"line": heading}), {}))

    size = base_size
    resolved = None
    warned_floor = False
    while size >= absolute_min_size:
        font = _resolve_font(font_path, size)
        line_step = max(1, round(line_height * (size / base_size)))
        wrapped_lines = []

        for tokens, line_cfg in paragraphs:
            line_max_width = line_cfg.get("max_width", max_width)
            paragraph_lines = _wrap_paragraph(draw, tokens, font, line_max_width)
            wrapped_lines.extend((line, line_cfg, line_max_width) for line in paragraph_lines)

        total_height = max(0, len(wrapped_lines) * line_step)
        if len(wrapped_lines) <= max_lines and total_height <= max_height:
            resolved = (font, line_step, wrapped_lines)
            break

        if fit_mode != "shrink_to_fit":
            break

        width_ratio = 1.0
        for line, _, line_max_width in wrapped_lines:
            line_w, _ = _measure_line(draw, line, font)
            if line_w > line_max_width:
                width_ratio = min(width_ratio, line_max_width / line_w)

        height_ratio = 1.0
        if total_height > max_height and total_height > 0:
            height_ratio = min(height_ratio, max_height / total_height)

        shrink_ratio = min(width_ratio, height_ratio)
        next_size = size - 1
        if shrink_ratio < 1.0:
            next_size = min(next_size, max(absolute_min_size, int(size * shrink_ratio * 0.98)))

        if size > min_size and next_size < min_size and not warned_floor:
            print(
                f"WARN: shrinking heading below preferred min size for box {max_width}x{max_height}"
            )
            warned_floor = True

        if next_size >= size:
            next_size = size - 1

        size = next_size

    if resolved is None and size < absolute_min_size:
        size = absolute_min_size
        font = _resolve_font(font_path, size)
        line_step = max(1, round(line_height * (size / base_size)))
        wrapped_lines = []
        for tokens, line_cfg in paragraphs:
            line_max_width = line_cfg.get("max_width", max_width)
            paragraph_lines = _wrap_paragraph(draw, tokens, font, line_max_width)
            wrapped_lines.extend((line, line_cfg, line_max_width) for line in paragraph_lines)
        resolved = (font, line_step, wrapped_lines)

    if resolved is None:
        print(
            f"WARN: heading does not fit box at format size {base_size}px "
            f"for box {max_width}x{max_height}; rendering best effort"
        )
        font = _resolve_font(font_path, absolute_min_size)
        line_step = max(1, round(line_height * (absolute_min_size / base_size)))
        wrapped_lines = []
        for tokens, line_cfg in paragraphs:
            line_max_width = line_cfg.get("max_width", max_width)
            paragraph_lines = _wrap_paragraph(draw, tokens, font, line_max_width)
            wrapped_lines.extend((line, line_cfg, line_max_width) for line in paragraph_lines)
        resolved = (font, line_step, wrapped_lines)

    font, line_step, wrapped_lines = resolved

    if wrapped_lines:
        max_fit_height = max_height // len(wrapped_lines)
        if max_fit_height > 0:
            line_step = min(line_step, max(1, max_fit_height))

    for idx, (line, line_cfg, line_max_width) in enumerate(wrapped_lines):
        line_align = line_cfg.get("align", align)
        line_w, _ = _measure_line(draw, line, font)

        if line_align == "center":
            line_x = x + (line_max_width - line_w) // 2
        elif line_align == "right":
            line_x = x + line_max_width - line_w
        else:
            line_x = x

        _draw_segments(draw, line, line_x, y + idx * line_step, font, colors)


def _is_ios_format(fmt):
    return fmt == "ios"


def generate(
    base_dir, layout_path, copy_dir, output_dir, formats, locales,
    skip_missing, font_path,
):
    layout = _load_yaml(layout_path)
    _validate_layout(layout, layout_path)

    layout_formats = layout.get("formats", {})

    copy_files = list(copy_dir.glob("*.yaml")) + list(copy_dir.glob("*.yml"))
    copy_files = [f for f in copy_files if f.name != "layout.yaml"]
    if not copy_files:
        print(f"ERROR: No copy files found in {copy_dir}")
        sys.exit(1)

    copy_data = {}
    copy_paths = {}
    for f in sorted(copy_files):
        locale = f.stem
        copy_data[locale] = _load_yaml(f)
        copy_paths[locale] = f

    if locales:
        missing = [l for l in locales if l not in copy_data]
        if missing:
            print(f"ERROR: Missing copy for locales: {', '.join(missing)}")
            sys.exit(1)
        copy_data = {l: copy_data[l] for l in locales}

    if not copy_data:
        print("ERROR: No locale copy data loaded")
        sys.exit(1)

    for fmt in formats:
        if fmt not in layout_formats:
            print(f"WARN: format '{fmt}' not in layout, skipping")
            continue

        fmt_cfg = layout_formats[fmt]
        fmt_assets = fmt_cfg["assets"]

        for locale, data in copy_data.items():
            _validate_copy(data, copy_paths[locale], fmt_assets)

        for locale, data in copy_data.items():
            locale_output = output_dir / fmt / locale
            locale_output.mkdir(parents=True, exist_ok=True)

            for screenshot in data["screenshots"]:
                aid = screenshot["asset"]
                asset_cfg = fmt_assets[aid]
                source = asset_cfg["source"]
                heading = screenshot["heading"]

                base_path = base_dir / _format_base_subdir(fmt) / source

                if not base_path.exists():
                    if skip_missing:
                        print(f"  SKIP {locale}/{fmt}/{source}: base image not found")
                        continue
                    else:
                        print(f"ERROR: Base image not found: {base_path}")
                        sys.exit(1)

                img = Image.open(base_path).convert("RGB")
                draw = ImageDraw.Draw(img)

                _render_heading(draw, heading, asset_cfg, font_path, COLORS)

                output_path = locale_output / source.replace(".jpg", ".png")
                img.save(output_path, "PNG")
                print(f"  OK   {locale}/{fmt}/{output_path.name}")

        if _is_ios_format(fmt):
            for locale, data in copy_data.items():
                if "name" in data and data["name"]:
                    name_path = output_dir / fmt / locale / "name.txt"
                    with open(name_path, "w") as f:
                        f.write(data["name"] + "\n")
                    print(f"  NAME {locale}/{fmt}/name.txt")

    print("\nDone.")


def main():
    parser = argparse.ArgumentParser(
        description="Generate localized store screenshots"
    )
    parser.add_argument("--base-dir", default=str(DEFAULT_BASE_DIR))
    parser.add_argument("--layout", default=str(DEFAULT_LAYOUT))
    parser.add_argument("--copy-dir", default=str(DEFAULT_COPY_DIR))
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR))
    parser.add_argument("--font", default=str(DEFAULT_FONT))
    parser.add_argument(
        "--formats", default="ios,android",
        help="Comma-separated: ios, android, all",
    )
    parser.add_argument("--locale", help="Generate only this locale")
    parser.add_argument(
        "--skip-missing", action="store_true",
        help="Skip missing base images",
    )
    args = parser.parse_args()

    formats = _resolve_formats(args.formats)
    locales = [args.locale] if args.locale else None

    generate(
        base_dir=Path(args.base_dir),
        layout_path=Path(args.layout),
        copy_dir=Path(args.copy_dir),
        output_dir=Path(args.output_dir),
        formats=formats,
        locales=locales,
        skip_missing=args.skip_missing,
        font_path=args.font,
    )


if __name__ == "__main__":
    main()
