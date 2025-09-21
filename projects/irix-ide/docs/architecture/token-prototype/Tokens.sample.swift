import SwiftUI

/// Auto-generated from tokens.sample.json (macOS profile)
struct Tokens {
    struct ColorPalette {
        static let bgBase = Color(hex: "#0F0F10")
        static let bgSurface = Color(hex: "#1E1E1E")
        static let focusAccent = Color(hex: "#4C6EF5")
    }

    struct Spacing {
        static let four: CGFloat = 16.0
    }

    struct Radius {
        static let small: CGFloat = 8.0
    }

    struct Typography {
        struct Heading {
            static let medium = Font.system(size: 22, weight: .semibold, design: .default)
        }
    }

    struct Icon {
        static let warning = Image(systemName: "exclamationmark.triangle.fill")
    }
}

private extension Color {
    init(hex: String) {
        self = Color(UIColor(hex: hex))
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var hexValue = hex
        if hex.hasPrefix("#") {
            hexValue = String(hex.dropFirst())
        }
        var int = UInt64()
        Scanner(string: hexValue).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255.0
        let g = CGFloat((int >> 8) & 0xFF) / 255.0
        let b = CGFloat(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
