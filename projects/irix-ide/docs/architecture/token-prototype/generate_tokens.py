from __future__ import annotations
import json
import argparse
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, Tuple

ROOT = Path(__file__).parent
DEFAULT_SOURCE = ROOT / "tokens.sample.json"
DEFAULT_OUTPUT_SWIFT = ROOT / "Tokens.generated.swift"
DEFAULT_OUTPUT_MOTIF = ROOT / "IRIXIDE.generated.ad"

MACOS_PROFILE = "macos"
MOTIF_PROFILE = "motif"


def load_tokens(path: Path) -> Dict[str, Any]:
    with path.open() as f:
        return json.load(f)


def resolve_value(token_node: Dict[str, Any], profile: str) -> Any:
    overrides = token_node.get("platformOverrides", {})
    if profile == MACOS_PROFILE:
        # macOS profile uses base value directly
        return token_node.get("value", token_node)
    if profile in overrides:
        return overrides[profile]
    return token_node.get("value", token_node)


def pascal_case(name: str) -> str:
    if not name:
        return name
    return name[0].upper() + name[1:]


def generate_swift(data: Dict[str, Any]) -> str:
    colors = data["tokens"]["color"]
    spacing = data["tokens"].get("spacing", {})
    radius = data["tokens"].get("radius", {})
    typography = data["tokens"].get("typography", {})
    icons = data["tokens"].get("icon", {})

    def swift_color(value: str) -> str:
        return f'Color(hex: "{value}")'

    swift_lines = [
        "import SwiftUI",
        "",
        "/// Auto-generated from tokens.sample.json (macOS profile)",
        "struct Tokens {",
        "    struct ColorPalette {",
    ]

    for group_name, group in colors.items():
        for token_name, token in group.items():
            value = resolve_value(token, MACOS_PROFILE)
            swift_lines.append(
                f'        static let {group_name}{pascal_case(token_name)} = {swift_color(value)}'
            )

    swift_lines.extend([
        "    }",
        "",
        "    struct Spacing {",
    ])

    for name, token in spacing.items():
        value = resolve_value(token, MACOS_PROFILE)
        swift_lines.append(f"        static let s{name} = CGFloat({value})")

    swift_lines.extend([
        "    }",
        "",
        "    struct Radius {",
    ])

    for name, token in radius.items():
        value = resolve_value(token, MACOS_PROFILE)
        swift_lines.append(f"        static let {name} = CGFloat({value})")

    swift_lines.extend([
        "    }",
        "",
        "    struct Typography {",
    ])

    for group_name, group in typography.items():
        swift_lines.append(f"        struct {pascal_case(group_name)} {{")
        for token_name, token in group.items():
            value = resolve_value(token, MACOS_PROFILE)
            font_family = value.get("fontFamily", "System")
            font_size = value.get("fontSize", 17)
            weight = value.get("fontWeight", "regular")
            weight_swift = weight_mapping(weight)
            swift_lines.append(
                f"            static let {token_name} = Font.custom(\"{font_family}\", size: {font_size}).weight(.{weight_swift})"
            )
        swift_lines.append("        }")

    swift_lines.extend([
        "    }",
        "",
        "    struct Icon {",
    ])

    for name, token in icons.items():
        value = resolve_value(token, MACOS_PROFILE)
        swift_lines.append(f'        static let {name} = Image(systemName: "{value}")')

    swift_lines.extend([
        "    }",
        "}",
    ])

    swift_lines.extend([
        "",
        "private extension Color {",
        "    init(hex: String) {",
        "        self = Color(UIColor(hex: hex))",
        "    }",
        "}",
        "",
        "private extension UIColor {",
        "    convenience init(hex: String) {",
        "        var hexValue = hex",
        "        if hexValue.hasPrefix(\"#\") {",
        "            hexValue = String(hexValue.drop(1))",
        "        }",
        "        var int: UInt64 = 0",
        "        Scanner(string: hexValue).scanHexInt64(&int)",
        "        let r = CGFloat((int >> 16) & 0xFF) / 255.0",
        "        let g = CGFloat((int >> 8) & 0xFF) / 255.0",
        "        let b = CGFloat(int & 0xFF) / 255.0",
        "        self.init(red: r, green: g, blue: b, alpha: 1.0)",
        "    }",
        "}",
    ])

    return "\n".join(swift_lines)


def generate_motif(data: Dict[str, Any]) -> str:
    tokens = data["tokens"]
    lines = ["! Auto-generated from tokens.sample.json (motif profile)"]

    def emit_color(path: str, node: Dict[str, Any]) -> None:
        lines.append(
            f"IRIXIDE*{path}:            {resolve_value(node, MOTIF_PROFILE)}"
        )

    colors = tokens.get("color", {})
    bg_group = colors.get("bg", {})
    if "base" in bg_group:
        emit_color("color.bg.base", bg_group["base"])
    if "surface" in bg_group:
        emit_color("color.bg.surface", bg_group["surface"])
    if "panel" in bg_group:
        emit_color("color.bg.panel", bg_group["panel"])

    focus_group = colors.get("focus", {})
    if "accent" in focus_group:
        emit_color("color.focus.accent", focus_group["accent"])

    text_group = colors.get("text", {})
    if "primary" in text_group:
        emit_color("color.text.primary", text_group["primary"])
    if "secondary" in text_group:
        emit_color("color.text.secondary", text_group["secondary"])

    for status_name, node in colors.get("status", {}).items():
        emit_color(f"color.status.{status_name.lower()}", node)

    spacing_tokens = tokens.get("spacing", {})
    for name, token in spacing_tokens.items():
        value = resolve_value(token, MOTIF_PROFILE)
        if isinstance(value, dict) and "scale" in value:
            value = value["scale"] * token.get("value", 0)
        lines.append(f"IRIXIDE*spacing.s{name}:       {int(round(value))}")

    radius_tokens = tokens.get("radius", {})
    for name, token in radius_tokens.items():
        value = resolve_value(token, MOTIF_PROFILE)
        lines.append(f"IRIXIDE*radius.{name}:          {int(round(value))}")

    typography_tokens = tokens.get("typography", {})

    def motif_font_entry(group: str, name: str, node: Dict[str, Any]) -> None:
        value = resolve_value(node, MOTIF_PROFILE)
        font_family = value.get("fontFamily", "helvetica").lower()
        font_size = value.get("fontSize", 15)
        group_slug = group.lower()
        token_slug = name.lower()
        lines.append(
            f"IRIXIDE*font.{group_slug}.{token_slug}:     -*-{font_family}-medium-r-normal-*-{font_size}-*"
        )

    for group_name, group in typography_tokens.items():
        for token_name, node in group.items():
            motif_font_entry(group_name, token_name, node)

    icon_tokens = tokens.get("icon", {})
    for name, token in icon_tokens.items():
        value = resolve_value(token, MOTIF_PROFILE)
        lines.append(f"IRIXIDE*icon.{name.lower()}:    @{value}")

    return "\n".join(lines)


def weight_mapping(weight: str) -> str:
    mapping = {
        "regular": "regular",
        "semibold": "semibold",
        "bold": "bold",
        "medium": "medium",
        "light": "light",
    }
    return mapping.get(weight.lower(), "regular")


def validate_colors(color_items: Iterable[Tuple[str, str]]) -> None:
    for token_id, value in color_items:
        if not isinstance(value, str) or not value.startswith("#") or len(value) not in (4, 7):
            print(f"[warn] token {token_id} has non-hex color value '{value}'", file=sys.stderr)


def gather_color_tokens(data: Dict[str, Any]) -> Iterable[Tuple[str, str]]:
    colors = data.get("tokens", {}).get("color", {})
    for family, tokens in colors.items():
        for name, node in tokens.items():
            value = resolve_value(node, MACOS_PROFILE)
            yield f"color.{family}.{name}", value


def contrast_ratio(fg_hex: str, bg_hex: str) -> float:
    def to_rgb(hex_value: str) -> Tuple[float, float, float]:
        hv = hex_value.lstrip('#')
        if len(hv) == 3:
            hv = ''.join(ch * 2 for ch in hv)
        r = int(hv[0:2], 16) / 255.0
        g = int(hv[2:4], 16) / 255.0
        b = int(hv[4:6], 16) / 255.0
        return r, g, b

    def luminance(rgb: Tuple[float, float, float]) -> float:
        def channel(c: float) -> float:
            return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

        r, g, b = map(channel, rgb)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b

    l1 = luminance(to_rgb(fg_hex))
    l2 = luminance(to_rgb(bg_hex))
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def run_validations(data: Dict[str, Any]) -> None:
    color_items = list(gather_color_tokens(data))
    validate_colors(color_items)
    # Contrast check for primary text on background
    colors = data.get("tokens", {}).get("color", {})
    try:
        bg_base = resolve_value(colors["bg"]["base"], MACOS_PROFILE)
        text_primary = resolve_value(colors["text"]["primary"], MACOS_PROFILE)
        ratio = contrast_ratio(text_primary, bg_base)
        if ratio < 4.5:
            print(
                f"[warn] contrast ratio between color.text.primary and color.bg.base is {ratio:.2f} (< 4.5)",
                file=sys.stderr,
            )
    except KeyError:
        print("[info] Skipping contrast check; required tokens missing", file=sys.stderr)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate platform token outputs from JSON definition")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help="Path to token JSON definition")
    parser.add_argument("--swift-out", type=Path, default=DEFAULT_OUTPUT_SWIFT, help="Swift output file path")
    parser.add_argument("--motif-out", type=Path, default=DEFAULT_OUTPUT_MOTIF, help="Motif .ad output file path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    data = load_tokens(args.source)
    run_validations(data)
    swift_output = generate_swift(data)
    motif_output = generate_motif(data)
    args.swift_out.write_text(swift_output + "\n")
    args.motif_out.write_text(motif_output + "\n")
    def pretty_path(path: Path) -> str:
        try:
            return str(path.relative_to(ROOT))
        except ValueError:
            return str(path)

    print(f"Generated {pretty_path(args.swift_out)}")
    print(f"Generated {pretty_path(args.motif_out)}")


if __name__ == "__main__":
    main()
