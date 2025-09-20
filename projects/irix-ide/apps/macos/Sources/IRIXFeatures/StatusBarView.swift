import SwiftUI
import IRIXServices
import IRIXDesignSystem

struct StatusBarView: View {
    let connectionState: ConnectionState

    var body: some View {
        HStack {
            StatusBadge(state: connectionState)
            Spacer()
            Button {
                // future: trigger command palette
            } label: {
                Label("Command Palette", systemImage: "command")
            }
            .buttonStyle(.bordered)
        }
        .padding(DesignTokens.Spacing.md)
        .background(DesignTokens.ColorPalette.backgroundPanel.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
}
