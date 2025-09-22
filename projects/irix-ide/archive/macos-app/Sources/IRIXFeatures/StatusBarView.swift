import SwiftUI
import IRIXServices
import IRIXDesignSystem

struct StatusBarView: View {
    let connectionState: ConnectionState
    let latestBuild: BuildSummary?

    var body: some View {
        HStack {
            StatusBadge(state: connectionState)
            if let latestBuild {
                Text("Latest build: \(latestBuild.label) · \(statusLabel(for: latestBuild.status))")
                    .foregroundColor(color(for: latestBuild.status))
            }
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

    private func statusLabel(for status: BuildSummary.Status) -> String {
        switch status {
        case .queued: return "Queued"
        case .running: return "Running"
        case .succeeded: return "Succeeded"
        case .failed: return "Failed"
        }
    }

    private func color(for status: BuildSummary.Status) -> Color {
        switch status {
        case .queued: return DesignTokens.ColorPalette.textMuted
        case .running: return DesignTokens.ColorPalette.accent
        case .succeeded: return DesignTokens.ColorPalette.success
        case .failed: return DesignTokens.ColorPalette.danger
        }
    }
}
