import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct StatusBadge: View {
    let state: ConnectionState

    public init(state: ConnectionState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(color.opacity(0.2))
        .clipShape(Capsule())
    }

    private var label: String {
        switch state {
        case .connected: return "Connected"
        case .degraded: return "Degraded"
        case let .reconnecting(attempt, max): return "Retry \(attempt)/\(max)"
        case let .offline(reason): return reason.map { "Offline: \($0)" } ?? "Offline"
        }
    }

    private var color: Color {
        switch state {
        case .connected: return DesignTokens.ColorPalette.success
        case .degraded: return DesignTokens.ColorPalette.warning
        case .reconnecting: return DesignTokens.ColorPalette.accent
        case .offline: return DesignTokens.ColorPalette.danger
        }
    }
}
