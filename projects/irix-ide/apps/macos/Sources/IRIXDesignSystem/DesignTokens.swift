import SwiftUI

public enum DesignTokens {
    public enum ColorPalette {
        public static let backgroundBase = Color(hex: "0F0F10")
        public static let backgroundSurface = Color(hex: "1E1E1E")
        public static let backgroundPanel = Color(hex: "2C2C2E")
        public static let accent = Color(hex: "4C6EF5")
        public static let success = Color(hex: "34C759")
        public static let warning = Color(hex: "FFD60A")
        public static let danger = Color(hex: "FF3B30")
        public static let textPrimary = Color(hex: "F2F2F7")
        public static let textSecondary = Color(hex: "D1D1D6")
        public static let textMuted = Color(hex: "8E8E93")
    }

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    public enum Radius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 20
    }
}

extension Color {
    public init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: value).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch value.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
