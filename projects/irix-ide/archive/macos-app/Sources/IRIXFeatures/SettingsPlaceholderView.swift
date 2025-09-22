import SwiftUI
import IRIXDesignSystem

public struct SettingsPlaceholderView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Settings")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
            settingsSection(title: "Profile", items: ["Name: Alex Rivera", "SSH Key: ~/.ssh/irix_id_rsa", "Default Host: octane"])
            settingsSection(title: "Preferences", items: ["Theme: Dark", "Auto Sync: Enabled", "Undo Window: 5s"])
            settingsSection(title: "Notifications", items: ["Build Alerts: On", "Host Degradation: On", "Deploy Summary: Email"])
            Spacer()
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }

    private func settingsSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                Text(item)
                    .foregroundColor(DesignTokens.ColorPalette.textMuted)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.ColorPalette.backgroundPanel)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
    }
}
