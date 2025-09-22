#!/usr/bin/env python3
"""Convert SGI IconSmith .fti vector icon files into SVG.

The converter understands the core drawing primitives used by the IRIX
`iconlib` library (polygons, outline polygons, lines, closed lines, points) and
emits an SVG document with approximate colours. Numeric colour indices are
rendered as neutral greys so the geometry can be inspected; named colours such
as `iconcolor`, `outlinecolor`, and `shadowcolor` map to sensible defaults.
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Sequence, Tuple

# Default coordinate system is 0..100 (IconSmith grid)
VIEW_BOX_SIZE = 100.0

# Named colour mapping inspired by the IRIX guidelines.
NAMED_COLOURS = {
    "iconcolor": "#cfd4e5",
    "outlinecolor": "#000000",
    "shadowcolor": "#00000088",
    "highlightcolor": "#ffffff",
}


@dataclass
class Shape:
    kind: str  # polygon | polyline
    points: List[Tuple[float, float]]
    fill: Optional[str] = None
    stroke: Optional[str] = None
    stroke_width: float = 1.0
    close: bool = True


COLOR_RE = re.compile(r"color\(([^)]+)\);")
VERTEX_RE = re.compile(r"vertex\(([^,]+),\s*([^\)]+)\);")
END_OUTLINE_RE = re.compile(r"endoutlinepolygon\(([^)]+)\);")


def resolve_colour(token: str, base_fill: str | None = None) -> str:
    token = token.strip()
    if token.lower() in NAMED_COLOURS:
        return NAMED_COLOURS[token.lower()]
    try:
        value = int(token)
    except ValueError:
        return base_fill or "#888888"
    # Map numeric indices to a neutral grey ramp.
    norm = max(0.0, min(1.0, (-value) / 300.0))
    channel = int(round(220 - norm * 130))
    channel = max(0, min(255, channel))
    return f"#{channel:02x}{channel:02x}{channel:02x}"


def parse_fti(path: Path) -> List[Shape]:
    shapes: List[Shape] = []
    stack: List[Shape] = []
    current_colour = "#cfd4e5"

    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        colour_match = COLOR_RE.match(line)
        if colour_match:
            token = colour_match.group(1)
            if token.lower() in NAMED_COLOURS:
                current_colour = NAMED_COLOURS[token.lower()]
            else:
                current_colour = resolve_colour(token, current_colour)
            continue

        if line.startswith("bgnpolygon"):
            stack.append(Shape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True))
            continue
        if line.startswith("bgnoutlinepolygon"):
            stack.append(Shape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True))
            stack[-1].stroke_width = 1.2
            stack[-1].stroke = None  # will be set by endoutlinepolygon
            continue
        if line.startswith("bgnline"):
            stack.append(Shape(kind="polyline", points=[], fill=None, stroke=current_colour, stroke_width=1.5, close=False))
            continue
        if line.startswith("bgnclosedline"):
            stack.append(Shape(kind="polyline", points=[], fill=None, stroke=current_colour, stroke_width=1.5, close=True))
            continue
        if line.startswith("bgnpoint"):
            stack.append(Shape(kind="polygon", points=[], fill=current_colour, stroke=None, close=True))
            continue

        vertex_match = VERTEX_RE.match(line)
        if vertex_match:
            x = float(vertex_match.group(1))
            y = float(vertex_match.group(2))
            if not stack:
                continue
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
        if outline_match:
            if stack:
                shape = stack.pop()
                stroke_token = outline_match.group(1)
                shape.stroke = resolve_colour(stroke_token, "#000000")
                if shape.stroke == shape.fill:
                    shape.stroke = "#000000"
                shapes.append(shape)
            continue

    return shapes


def shapes_to_svg(shapes: Sequence[Shape]) -> str:
    def transform_point(pt: Tuple[float, float]) -> Tuple[float, float]:
        x, y = pt
        return x, VIEW_BOX_SIZE - y

    svg_elements: List[str] = []
    for shape in shapes:
        if not shape.points:
            continue
        points = [transform_point(p) for p in shape.points]
        point_str = " ".join(f"{x:.2f},{y:.2f}" for x, y in points)
        if shape.kind == "polygon" or shape.close:
            svg_elements.append(
                f'<polygon points="{point_str}" fill="{shape.fill or "none"}" '
                f'stroke="{shape.stroke or "none"}" stroke-width="{shape.stroke_width}" stroke-linejoin="round" />'
            )
        else:
            svg_elements.append(
                f'<polyline points="{point_str}" fill="none" '
                f'stroke="{shape.stroke or "#000"}" stroke-width="{shape.stroke_width}" stroke-linecap="round" stroke-linejoin="round" />'
            )
    svg_body = "\n  ".join(svg_elements)
    return (
        f"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 {VIEW_BOX_SIZE} {VIEW_BOX_SIZE}\" "
        f"width=\"{VIEW_BOX_SIZE}\" height=\"{VIEW_BOX_SIZE}\">\n  {svg_body}\n</svg>\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Path to the .fti file")
    parser.add_argument("output", type=Path, help="Destination SVG file")
    args = parser.parse_args()

    shapes = parse_fti(args.input)
    svg = shapes_to_svg(shapes)
    args.output.write_text(svg)
    print(f"Wrote SVG to {args.output}")


if __name__ == "__main__":
    main()
