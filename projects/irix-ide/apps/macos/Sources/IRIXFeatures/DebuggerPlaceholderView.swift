import SwiftUI
import IRIXDesignSystem

public struct DebuggerPlaceholderView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Debugger")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
            Text("GDB remote session integration coming soon. This placeholder references the layout in the design mockups (source pane, call stack, watch expressions, console).")
                .foregroundColor(DesignTokens.ColorPalette.textMuted)
            Spacer()
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }
}
