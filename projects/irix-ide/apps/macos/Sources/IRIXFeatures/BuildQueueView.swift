import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct BuildQueueView: View {
    let builds: [BuildSummary]
    let logLines: [String]
    let runBuildHandler: () -> Void

    public init(builds: [BuildSummary], logLines: [String], runBuildHandler: @escaping () -> Void) {
        self.builds = builds
        self.logLines = logLines
        self.runBuildHandler = runBuildHandler
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Build & Logs")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)

            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                buildTable
                logPanel
            }
            Spacer()
        }
        .padding(DesignTokens.Spacing.xl)
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }

    private var buildTable: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            ForEach(builds) { build in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(build.label)
                        .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                    Text(statusLabel(for: build.status))
                        .font(.caption)
                        .foregroundColor(statusColor(for: build.status))
                }
                .padding(DesignTokens.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignTokens.ColorPalette.backgroundPanel)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var logPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text("Live Logs")
                    .font(.headline)
                    .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                Spacer()
                Button("Run Build") {
                    runBuildHandler()
                }
                .buttonStyle(.borderedProminent)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    ForEach(logLines, id: \.self) { line in
                        Text(line)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(DesignTokens.ColorPalette.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(DesignTokens.Spacing.md)
            }
            .frame(width: 260, height: 320)
            .background(DesignTokens.ColorPalette.backgroundPanel)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
        }
    }

    private func statusLabel(for status: BuildSummary.Status) -> String {
        switch status {
        case .queued: return "Queued"
        case .running: return "Running"
        case .succeeded: return "Succeeded"
        case .failed: return "Failed"
        }
    }

    private func statusColor(for status: BuildSummary.Status) -> Color {
        switch status {
        case .queued: return DesignTokens.ColorPalette.textMuted
        case .running: return DesignTokens.ColorPalette.accent
        case .succeeded: return DesignTokens.ColorPalette.success
        case .failed: return DesignTokens.ColorPalette.danger
        }
    }
}
