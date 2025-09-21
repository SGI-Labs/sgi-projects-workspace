import SwiftUI

/// Auto-generated from tokens.sample.json (macOS profile)
struct Tokens {
    struct ColorPalette {
        static let bgBase = Color(hex: "#0F0F10")
        static let bgSurface = Color(hex: "#1E1E1E")
        static let bgPanel = Color(hex: "#2C2C2E")
        static let focusAccent = Color(hex: "#4C6EF5")
        static let textPrimary = Color(hex: "#F2F2F7")
        static let textSecondary = Color(hex: "#8E8E93")
        static let statusSuccess = Color(hex: "#34C759")
        static let statusWarning = Color(hex: "#FFD60A")
        static let statusDanger = Color(hex: "#FF3B30")
        static let statusOffline = Color(hex: "#FF9500")
        static let statusIrixAccent = Color(hex: "#6699CC")
    }

    struct Spacing {
        static let s4 = CGFloat(16)
    }

    struct Radius {
        static let sm = CGFloat(8)
    }

    struct Typography {
        struct Heading {
            static let lg = Font.custom("SF Pro Display", size: 28).weight(.bold)
            static let md = Font.custom("SF Pro Display", size: 22).weight(.semibold)
        }
        struct Body {
            static let base = Font.custom("SF Pro Text", size: 15).weight(.regular)
            static let monoSm = Font.custom("SF Mono", size: 13).weight(.regular)
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
        if hexValue.hasPrefix("#") {
            hexValue = String(hexValue.drop(1))
        }
        var int: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255.0
        let g = CGFloat((int >> 8) & 0xFF) / 255.0
        let b = CGFloat(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
