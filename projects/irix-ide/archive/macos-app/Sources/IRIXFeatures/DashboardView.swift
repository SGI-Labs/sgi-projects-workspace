import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct DashboardView: View {
    let hosts: [IRIXServices.Host]
    let builds: [BuildSummary]

    public init(hosts: [IRIXServices.Host], builds: [BuildSummary]) {
        self.hosts = hosts
        self.builds = builds
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text("Dashboard")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(DesignTokens.ColorPalette.textPrimary)

                metricsRow
                recentActivity
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }

    private var metricsRow: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            MetricCard(title: "Connected Hosts", value: "\(hosts.filter { $0.state == .connected }.count)/\(hosts.count)", accent: DesignTokens.ColorPalette.success)
            MetricCard(title: "Active Builds", value: "\(builds.filter { $0.status == .running }.count)", accent: DesignTokens.ColorPalette.accent)
            MetricCard(title: "Alerts", value: "\(hosts.filter { if case .degraded = $0.state { return true }; if case .offline = $0.state { return true }; return false }.count)", accent: DesignTokens.ColorPalette.warning)
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Recent Activity")
                .font(.title3.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)

            ForEach(builds) { build in
                HStack {
                    Text(build.label)
                        .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                    Spacer()
                    Text(statusLabel(for: build.status))
                        .foregroundColor(statusColor(for: build.status))
                        .font(.footnote)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(DesignTokens.ColorPalette.backgroundPanel)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
            }
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

struct MetricCard: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .foregroundColor(DesignTokens.ColorPalette.textMuted)
                .font(.footnote)
            Text(value)
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                .font(.title2.weight(.semibold))
            Rectangle()
                .fill(accent)
                .frame(height: 4)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DesignTokens.ColorPalette.backgroundPanel)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
    }
}
