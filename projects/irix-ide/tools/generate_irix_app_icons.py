#!/usr/bin/env python3
"""Generate macOS app icons from authentic SGI IRIX icon sources.

The generator can consume any of the following as the foreground artwork:

* IconSmith `.fti` vector files (rendered directly into RGBA layers)
* IconSmith `.ftr` rule files (which compose multiple `.fti` layers)
* Classic SGI `.icon` RGBA bitmaps (with background removal)

All variants are composited onto the Indigo Magic inspired backdrop, then
exported to the full macOS `AppIcon.appiconset` including dark/tinted
appearance overrides that only affect the icon-color regions.
"""
from __future__ import annotations

import argparse
import json
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import List, Sequence, Tuple

import re

from PIL import Image, ImageColor, ImageDraw, ImageEnhance, ImageFilter, ImageOps

# Target output directory relative to repo root.
DEFAULT_ICONSET_PATH = Path(
    "projects/irix-ide/apps/macos/IRIX IDE/IRIX IDE/Assets.xcassets/AppIcon.appiconset"
)

# Authentic SGI palette accents.
ICON_COLOR_NEUTRAL = "#ced3de"  # base icon-color neutral tone
ICON_COLOR_ACTIVE = "#57d8ff"   # highlight tone used for active state

SGI_BACKGROUND_DARK = "#0b0715"
SGI_BACKGROUND_INDIGO = "#35205c"
SGI_BACKGROUND_GLOW = "#d0d0d6"

# Default SGI icon source; overridable via CLI.
DEFAULT_SGI_ICON = Path("/Volumes/Irix/usr/lib/images/development.icon")

# Optional IconSmith vector source.
DEFAULT_FTI_PATH = Path("/Volumes/Irix/usr/lib/filetype/iconlib/generic.exec.closed.fti")
DEFAULT_FTR_PATH = Path("/Volumes/Irix/usr/lib/filetype/default/sgidefault.ftr")


@dataclass
class FtiShape:
    kind: str  # polygon | polyline
    points: List[Tuple[float, float]]
    fill: str | None = None
    stroke: str | None = None
    stroke_width: float = 1.0
    close: bool = True


@dataclass(frozen=True)
class IconSpec:
    idiom: str
    size: int
    scale: int
    filename: str
    platform: str | None = None
    appearances: Sequence[dict] | None = None

    @property
    def json_entry(self) -> dict:
        entry = {
            "idiom": self.idiom,
            "size": f"{self.size}x{self.size}",
            "scale": f"{self.scale}x",
            "filename": self.filename,
        }
        if self.platform:
            entry["platform"] = self.platform
        if self.appearances:
            entry["appearances"] = list(self.appearances)
        return entry


ICON_SPECS: List[IconSpec] = [
    IconSpec("universal", 1024, 1, "AppIcon-Universal-1024.png", platform="ios"),
    IconSpec(
        "universal",
        1024,
        1,
        "AppIcon-Universal-1024-Dark.png",
        platform="ios",
        appearances=({"appearance": "luminosity", "value": "dark"},),
    ),
    IconSpec(
        "universal",
        1024,
        1,
        "AppIcon-Universal-1024-Tinted.png",
        platform="ios",
        appearances=({"appearance": "luminosity", "value": "tinted"},),
    ),
    IconSpec("mac", 16, 1, "AppIcon-mac-16.png"),
    IconSpec("mac", 16, 2, "AppIcon-mac-16@2x.png"),
    IconSpec("mac", 32, 1, "AppIcon-mac-32.png"),
    IconSpec("mac", 32, 2, "AppIcon-mac-32@2x.png"),
    IconSpec("mac", 128, 1, "AppIcon-mac-128.png"),
    IconSpec("mac", 128, 2, "AppIcon-mac-128@2x.png"),
    IconSpec("mac", 256, 1, "AppIcon-mac-256.png"),
    IconSpec("mac", 256, 2, "AppIcon-mac-256@2x.png"),
    IconSpec("mac", 512, 1, "AppIcon-mac-512.png"),
    IconSpec("mac", 512, 2, "AppIcon-mac-512@2x.png"),
]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def hex_to_rgba(value: str, alpha: int = 255) -> Tuple[int, int, int, int]:
    value = value.lstrip("#")
    r = int(value[0:2], 16)
    g = int(value[2:4], 16)
    b = int(value[4:6], 16)
    return (r, g, b, alpha)


def create_background(size: int) -> Image.Image:
    """Craft the indigo vignette with a top-left glow."""
    base = Image.new("RGBA", (size, size), hex_to_rgba(SGI_BACKGROUND_DARK))

    diag = Image.linear_gradient("L").rotate(45, expand=True).resize((size, size))
    diag_colored = ImageOps.colorize(diag, SGI_BACKGROUND_DARK, SGI_BACKGROUND_INDIGO).convert("RGBA")
    diag_colored.putalpha(200)
    base = Image.alpha_composite(base, diag_colored)

    highlight = Image.radial_gradient("L").resize((size * 2, size * 2)).crop((0, 0, size, size))
    highlight_colored = ImageOps.colorize(highlight, SGI_BACKGROUND_INDIGO, SGI_BACKGROUND_GLOW).convert("RGBA")
    highlight_colored.putalpha(95)
    base = Image.alpha_composite(base, highlight_colored)

    vignette = Image.radial_gradient("L").resize((size, size)).rotate(180)
    vignette_colored = ImageOps.colorize(vignette, SGI_BACKGROUND_DARK, "#000000").convert("RGBA")
    vignette_colored.putalpha(120)
    base = Image.alpha_composite(base, vignette_colored)

    return base


def load_sgi_icon(path: Path, tolerance: int = 8) -> Image.Image:
    """Load an SGI `.icon` (SGI RGB) image and punch out its flat background."""
    icon = Image.open(path).convert("RGBA")
    pixels = list(icon.getdata())
    width, height = icon.size

    corners = [
        pixels[0],
        pixels[width - 1],
        pixels[(height - 1) * width],
        pixels[-1],
    ]
    most_common = Counter(pixels).most_common(2)
    background_candidates = {color for color, _ in most_common[:2]} | set(corners)

    cleaned = []
    for (r, g, b, a) in pixels:
        transparent = False
        for cr, cg, cb, _ in background_candidates:
            if abs(r - cr) <= tolerance and abs(g - cg) <= tolerance and abs(b - cb) <= tolerance:
                transparent = True
                break
        if transparent:
            cleaned.append((r, g, b, 0))
        else:
            cleaned.append((r, g, b, 255))
    icon.putdata(cleaned)
    return icon


COLOR_RE = re.compile(r"color\(([^)]+)\);")
VERTEX_RE = re.compile(r"vertex\(([^,]+),\s*([^\)]+)\);")
END_OUTLINE_RE = re.compile(r"endoutlinepolygon\(([^)]+)\);")


def resolve_fti_colour(token: str, base_fill: str | None = None) -> str:
    token = token.strip()
    key = token.lower()
    if key == "iconcolor":
        return "#cfd4e5"
    if key == "outlinecolor":
        return "#000000"
    if key == "shadowcolor":
        return "#00000088"
    if key == "highlightcolor":
        return "#ffffff"
    try:
        value = int(token)
    except ValueError:
        return base_fill or "#888888"

    palette = {
        -238: "#dcdce7",
        -200: "#c5d5f5",
        -176: "#b7c7ec",
        -168: "#a2b4de",
        -136: "#8091c4",
        -135: "#778abf",
        -128: "#9ba6cc",
        -119: "#e6e8f1",
        -102: "#5d73ad",
        -85: "#42548f",
        -84: "#415a9f",
        -68: "#324381",
        -51: "#9f6f6f",
        -32: "#6c88ba",
        -17: "#dfe3ef",
        -1: "#f7f8fc",
    }
    if value in palette:
        return palette[value]
    norm = max(0.0, min(1.0, (-value) / 320.0))
    channel = int(round(235 - norm * 150))
    channel = max(0, min(255, channel))
    return f"#{channel:02x}{channel:02x}{channel:02x}"


def parse_fti(path: Path) -> List[FtiShape]:
    shapes: List[FtiShape] = []
    stack: List[FtiShape] = []
    current_colour = "#cfd4e5"

    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        colour_match = COLOR_RE.match(line)
        if colour_match:
            current_colour = resolve_fti_colour(colour_match.group(1), current_colour)
            continue

        if line.startswith("bgnpolygon"):
            stack.append(FtiShape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True))
            continue
        if line.startswith("bgnoutlinepolygon"):
            stack.append(FtiShape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True, stroke_width=1.2))
            continue
        if line.startswith("bgnline"):
            stack.append(FtiShape(kind="polyline", points=[], fill=None, stroke=current_colour, stroke_width=1.5, close=False))
            continue
        if line.startswith("bgnclosedline"):
            stack.append(FtiShape(kind="polyline", points=[], fill=None, stroke=current_colour, stroke_width=1.5, close=True))
            continue
        if line.startswith("bgnpoint"):
            stack.append(FtiShape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True))
            continue

        vertex_match = VERTEX_RE.match(line)
        if vertex_match and stack:
            x = float(vertex_match.group(1))
            y = float(vertex_match.group(2))
            stack[-1].points.append((x, y))
            continue

        if line.startswith("endpolygon"):
            if stack:
                shapes.append(stack.pop())
            continue
        if line.startswith("endline") or line.startswith("endclosedline") or line.startswith("endpoint"):
            if stack:
                shapes.append(stack.pop())
            continue
        outline_match = END_OUTLINE_RE.match(line)
        if outline_match and stack:
            shape = stack.pop()
            stroke = resolve_fti_colour(outline_match.group(1), "#000000")
            shape.stroke = stroke
            shapes.append(shape)

    return shapes


def render_fti_shapes(shapes: List[FtiShape], size: int, margin_ratio: float = 0.72) -> Tuple[Image.Image, Image.Image]:
    if not shapes:
        empty = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        return empty, Image.new("L", (size, size), 0)

    xs = [x for shape in shapes for x, _ in shape.points]
    ys = [y for shape in shapes for _, y in shape.points]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    width = max(1e-4, max_x - min_x)
    height = max(1e-4, max_y - min_y)
    scale = margin_ratio * size / max(width, height)

    content_w = width * scale
    content_h = height * scale
    offset_x = (size - content_w) / 2
    offset_y = (size - content_h) / 2

    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")

    for shape in shapes:
        if not shape.points:
            continue
        # IconSmith origin (0,0) is bottom-left; flip vertically.
        transformed = []
        for x, y in shape.points:
            tx = offset_x + (x - min_x) * scale
            ty = offset_y + (y - min_y) * scale
            transformed.append((tx, size - ty))

        if shape.kind == "polygon" or shape.close:
            if shape.fill:
                draw.polygon(transformed, fill=shape.fill)
            if shape.stroke:
                pts = transformed + [transformed[0]] if shape.close else transformed
                draw.line(pts, fill=shape.stroke, width=max(1, int(shape.stroke_width * scale / 40)))
        else:
            pts = transformed + [transformed[0]] if shape.close else transformed
            stroke = shape.stroke or "#000000"
            width_px = max(1, int(shape.stroke_width * scale / 40))
            draw.line(pts, fill=stroke, width=width_px)

    mask = layer.split()[3]
    return layer, mask


def resolve_ftr_includes(ftr_path: Path, ftr_type: str | None = None, opened: bool = False) -> List[Path]:
    text = ftr_path.read_text()
    lines = text.splitlines()

    icons: dict[str, List[str]] = {}
    current_type: str | None = None
    capturing = False
    brace_depth = 0
    buffer: List[str] = []

    for raw in lines:
        line = raw.rstrip()
        stripped = line.strip()
        if stripped.startswith("TYPE "):
            current_type = stripped.split()[1]
        if "ICON" in stripped and current_type:
            # start capture when encountering first '{' after ICON
            start_idx = stripped.find("{")
            if start_idx != -1:
                capturing = True
                brace_depth = 1
                residual = stripped[start_idx + 1 :]
                if residual:
                    buffer.append(residual)
                    brace_depth += residual.count("{") - residual.count("}")
                if brace_depth == 0:
                    icons[current_type] = buffer.copy()
                    buffer.clear()
                    capturing = False
            continue
        if capturing:
            brace_depth += stripped.count("{")
            brace_depth -= stripped.count("}")
            if stripped and stripped != "}" * len(stripped):
                buffer.append(stripped)
            if brace_depth <= 0:
                icons[current_type] = buffer.copy()
                buffer.clear()
                capturing = False

    if not icons:
        return []

    if ftr_type and ftr_type in icons:
        icon_lines = icons[ftr_type]
    else:
        icon_lines = next(iter(icons.values()))

    expanded_lines: List[str] = []
    for raw in icon_lines:
        stripped = raw.strip()
        if stripped.startswith('} else'):
            expanded_lines.append('}')
            expanded_lines.append(stripped[stripped.find('else'):])
        else:
            expanded_lines.append(stripped)

    python_lines: List[str] = []
    indent = 0
    include_pattern = re.compile(r'include\("([^"]+)"\)')

    for stripped in expanded_lines:
        if not stripped:
            continue
        if stripped.startswith("if "):
            expr = stripped[stripped.find("(") + 1 : stripped.rfind(")")]
            expr = expr.replace("!", "not ").replace("&&", " and ").replace("||", " or ")
            python_lines.append("    " * indent + f"if {expr}:")
            indent += 1
            continue
        if stripped.startswith("else"):
            indent = max(indent - 1, 0)
            python_lines.append("    " * indent + "else:")
            indent += 1
            continue
        if stripped.startswith("}" ):
            indent = max(indent - 1, 0)
            continue
        match = include_pattern.search(stripped)
        if match:
            python_lines.append("    " * indent + f"add(Path('{match.group(1)}'))")

    scope: dict[str, object] = {"Path": Path, "opened": opened}
    includes: List[Path] = []

    def add(path: Path) -> None:
        includes.append(path)

    scope["add"] = add
    exec("\n".join(python_lines), scope, scope)
    return includes


def compose_icon(canvas: Image.Image, icon: Image.Image) -> Tuple[Image.Image, Image.Image]:
    """Place the SGI icon on the canvas, returning the composed image and mask."""
    size = canvas.size[0]
    # Scale icon to occupy roughly 60% width while leaving breathing room.
    max_width = int(size * 0.6)
    max_height = int(size * 0.55)
    scale = min(max_width / icon.width, max_height / icon.height)
    scale = max(scale, 1.0)  # avoid shrinking authentic art
    new_size = (int(round(icon.width * scale)), int(round(icon.height * scale)))
    icon_scaled = icon.resize(new_size, Image.NEAREST)

    pos_x = (size - icon_scaled.width) // 2
    pos_y = int(size * 0.62) - icon_scaled.height

    icon_alpha = icon_scaled.split()[3]

    # Drop shadow
    shadow = Image.new("RGBA", icon_scaled.size, (0, 0, 0, 0))
    shadow.putalpha(icon_alpha)
    shadow = ImageOps.colorize(shadow.convert("L"), "#000000", "#000000").convert("RGBA")
    shadow.putalpha(icon_alpha)
    shadow = shadow.filter(ImageFilter.GaussianBlur(max(8, size // 85)))

    shadow_offset = (pos_x + size // 90, pos_y + size // 70)
    base = canvas.copy()
    base.alpha_composite(shadow, shadow_offset)
    base.alpha_composite(icon_scaled, (pos_x, pos_y))

    mask = Image.new("L", (size, size), 0)
    mask.paste(icon_alpha, (pos_x, pos_y))

    return base, mask


def compose_layer_with_shadow(base: Image.Image, layer: Image.Image, mask: Image.Image, offset: Tuple[int, int]) -> Tuple[Image.Image, Image.Image]:
    composed = base.copy()
    if mask is not None:
        blur_radius = max(12, base.size[0] // 70)
        shadow_alpha = mask.filter(ImageFilter.GaussianBlur(blur_radius))
        shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
        shadow.paste((0, 0, 0, 150), mask=shadow_alpha)
        composed.alpha_composite(shadow, offset)
    composed.alpha_composite(layer)
    return composed, mask


def create_master_icon(
    size: int = 1024,
    source_icon: Path | None = None,
    fti_path: Path | None = None,
    ftr_path: Path | None = None,
    ftr_type: str | None = None,
    opened: bool = False,
) -> Tuple[Image.Image, Image.Image]:
    background = create_background(size)

    if ftr_path and ftr_path.exists():
        include_paths = resolve_ftr_includes(ftr_path, ftr_type=ftr_type, opened=opened)
        all_shapes: List[FtiShape] = []
        for include_path in include_paths:
            target = (ftr_path.parent / include_path).resolve()
            if target.exists():
                all_shapes.extend(parse_fti(target))
        if all_shapes:
            layer, mask = render_fti_shapes(all_shapes, size)
            composed, mask = compose_layer_with_shadow(background, layer, mask, (size // 90, size // 90))
            return composed, mask

    if fti_path and fti_path.exists():
        shapes = parse_fti(fti_path)
        layer, mask = render_fti_shapes(shapes, size)
        composed, mask = compose_layer_with_shadow(background, layer, mask, (size // 90, size // 90))
        return composed, mask

    if source_icon and source_icon.exists():
        icon = load_sgi_icon(source_icon)
        composed, mask = compose_icon(background, icon)
        return composed, mask

    raise FileNotFoundError("Provide either --fti or --source-icon for icon generation")


def apply_variant(image: Image.Image, icon_mask: Image.Image, variant: str) -> Image.Image:
    if variant == "dark":
        darkened = ImageEnhance.Brightness(image).enhance(0.82)
        cooled = ImageEnhance.Color(darkened).enhance(0.92)
        return cooled
    if variant == "tinted":
        overlay = Image.new("RGBA", image.size, hex_to_rgba(ICON_COLOR_ACTIVE))
        tint = Image.composite(overlay, image, icon_mask)
        return Image.blend(image, tint, 0.42)
    # neutral: add a soft icon-color glaze for cohesion.
    neutral_overlay = Image.new("RGBA", image.size, hex_to_rgba(ICON_COLOR_NEUTRAL, 60))
    return Image.alpha_composite(image, Image.composite(neutral_overlay, Image.new("RGBA", image.size, (0, 0, 0, 0)), icon_mask))


def export_icons(
    output_dir: Path,
    source_icon: Path | None,
    fti_path: Path | None,
    ftr_path: Path | None,
    ftr_type: str | None,
    opened: bool,
    overwrite: bool = True,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    master, icon_mask = create_master_icon(
        1024,
        source_icon=source_icon,
        fti_path=fti_path,
        ftr_path=ftr_path,
        ftr_type=ftr_type,
        opened=opened,
    )

    variants = {
        "regular": apply_variant(master, icon_mask, "regular"),
        "dark": apply_variant(master, icon_mask, "dark"),
        "tinted": apply_variant(master, icon_mask, "tinted"),
    }

    for spec in ICON_SPECS:
        if "Dark" in spec.filename:
            source = variants["dark"]
        elif "Tinted" in spec.filename:
            source = variants["tinted"]
        else:
            source = variants["regular"]

        pixel_size = spec.size * spec.scale
        icon = source.resize((pixel_size, pixel_size), Image.Resampling.LANCZOS)
        filepath = output_dir / spec.filename
        if not overwrite and filepath.exists():
            continue
        icon.save(filepath, format="PNG")

    write_contents_json(output_dir)


def write_contents_json(output_dir: Path) -> None:
    contents = {
        "images": [spec.json_entry for spec in ICON_SPECS],
        "info": {"author": "codex", "version": 1},
    }
    (output_dir / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--iconset",
        type=Path,
        default=DEFAULT_ICONSET_PATH,
        help="Path to the AppIcon.appiconset directory to populate",
    )
    parser.add_argument(
        "--source-icon",
        type=Path,
        default=DEFAULT_SGI_ICON,
        help="Path to an SGI .icon file to use as the foreground",
    )
    parser.add_argument(
        "--fti",
        type=Path,
        default=None,
        help="Path to an IconSmith .fti file to render as the foreground",
    )
    parser.add_argument(
        "--ftr",
        type=Path,
        default=None,
        help="Path to an FTR file that composes multiple .fti layers",
    )
    parser.add_argument(
        "--ftr-type",
        type=str,
        default=None,
        help="Specific TYPE block inside the FTR to render",
    )
    parser.add_argument(
        "--opened",
        action="store_true",
        help="Render the opened state for icons with conditionals",
    )
    parser.add_argument(
        "--no-overwrite",
        action="store_true",
        help="Skip writing files that already exist",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source_icon = args.source_icon if args.source_icon and args.source_icon.exists() else None
    fti_path = args.fti if args.fti and args.fti.exists() else None
    ftr_path = args.ftr if args.ftr and args.ftr.exists() else None

    if not ftr_path and DEFAULT_FTI_PATH.exists():
        # Use FTR fallback if explicit FTR not provided but default exists
        ftr_path = DEFAULT_FTI_PATH if DEFAULT_FTI_PATH.suffix == ".ftr" else None

    if not ftr_path and DEFAULT_FTR_PATH.exists():
        ftr_path = DEFAULT_FTR_PATH

    if not fti_path and DEFAULT_FTI_PATH.exists() and DEFAULT_FTI_PATH.suffix == ".fti":
        fti_path = DEFAULT_FTI_PATH
    if not source_icon and DEFAULT_SGI_ICON.exists():
        source_icon = DEFAULT_SGI_ICON

    if not any([ftr_path, fti_path, source_icon]):
        raise FileNotFoundError("Provide --ftr, --fti, or --source-icon for icon generation")

    ftr_type = args.ftr_type
    if ftr_path and ftr_type is None and ftr_path == DEFAULT_FTR_PATH:
        ftr_type = "GenericExecutable"

    export_icons(
        args.iconset,
        source_icon=source_icon,
        fti_path=fti_path,
        ftr_path=ftr_path,
        ftr_type=ftr_type,
        opened=args.opened,
        overwrite=not args.no_overwrite,
    )
    print(f"Generated IRIX-themed app icons in {args.iconset}")


if __name__ == "__main__":
    main()
