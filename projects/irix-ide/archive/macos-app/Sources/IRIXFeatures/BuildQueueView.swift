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
        Table(builds) {
            TableColumn("Build") { build in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(build.label)
                        .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                    Text(build.triggeredBy ?? "manual")
                        .font(.caption)
                        .foregroundColor(DesignTokens.ColorPalette.textMuted)
                }
            }
            TableColumn("Host") { build in
                Text(build.hostName ?? "—")
            }
            TableColumn("Status") { build in
                StatusBadge(state: statusToConnectionStatus(build.status))
            }
            TableColumn("Started") { build in
                Text(relativeTime(from: build.startedAt))
                    .foregroundColor(DesignTokens.ColorPalette.textMuted)
            }
            TableColumn("Duration") { build in
                Text(durationLabel(for: build))
                    .foregroundColor(DesignTokens.ColorPalette.textMuted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 320)
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
                    ForEach(logLines.indices, id: \.self) { index in
                        let line = logLines[index]
                        Text(line)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(colorForLogLine(line))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(DesignTokens.Spacing.md)
            }
            .frame(width: 320, height: 320)
            .background(DesignTokens.ColorPalette.backgroundPanel)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
        }
    }

    private func statusToConnectionStatus(_ status: BuildSummary.Status) -> ConnectionState {
        switch status {
        case .queued:
            return .degraded
        case .running:
            return .reconnecting(attempt: 1, maxAttempts: 1)
        case .succeeded:
            return .connected
        case .failed:
            return .offline(reason: "Build failed")
        }
    }

    private func durationLabel(for build: BuildSummary) -> String {
        if let duration = build.duration {
            return String(format: "%.0fs", duration)
        }
        if build.status == .running {
            let interval = Date().timeIntervalSince(build.startedAt)
            return String(format: "%.0fs", interval)
        }
        return "—"
    }

    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func colorForLogLine(_ line: String) -> Color {
        if line.localizedCaseInsensitiveContains("error") || line.localizedCaseInsensitiveContains("fail") {
            return DesignTokens.ColorPalette.danger
        }
        if line.localizedCaseInsensitiveContains("warning") {
            return DesignTokens.ColorPalette.warning
        }
        return DesignTokens.ColorPalette.textMuted
    }
}
