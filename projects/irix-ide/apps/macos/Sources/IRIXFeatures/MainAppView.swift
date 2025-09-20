import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct MainAppView: View {
    @ObservedObject private var viewModel: AppViewModel

    public init(viewModel: AppViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationSplitView {
            List(WorkspaceSection.allCases, selection: Binding(
                get: { viewModel.selectedSection },
                set: { viewModel.select(section: $0) }
            )) { section in
                Label(section.rawValue, systemImage: icon(for: section))
                    .tag(section)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220)
            .padding(.top, DesignTokens.Spacing.xs)
        } detail: {
            ZStack(alignment: .bottom) {
                detailView(for: viewModel.selectedSection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignTokens.ColorPalette.backgroundSurface)
                StatusBarView(connectionState: viewModel.connectionState)
                    .padding(DesignTokens.Spacing.md)
            }
            .background(DesignTokens.ColorPalette.backgroundBase)
        }
    }

    @ViewBuilder
    private func detailView(for section: WorkspaceSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(hosts: viewModel.hosts, builds: viewModel.builds)
        case .editor:
            PlaceholderView(title: "Editor", message: "Remote editing surface integrates with sync service (upcoming story).")
        case .remoteHosts:
            HostsView(hosts: viewModel.hosts) { host in
                viewModel.retry(host: host)
            }
        case .buildLogs:
            BuildQueueView(builds: viewModel.builds, logLines: viewModel.liveLogLines) {
                viewModel.runBuild()
            }
        case .debugger:
            DebuggerPlaceholderView()
        case .settings:
            SettingsPlaceholderView()
        }
    }

    private func icon(for section: WorkspaceSection) -> String {
        switch section {
        case .dashboard: return "speedometer"
        case .editor: return "doc.text"
        case .remoteHosts: return "server.rack"
        case .buildLogs: return "hammer"
        case .debugger: return "ladybug"
        case .settings: return "gearshape"
        }
    }
}

struct PlaceholderView: View {
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text(title)
                .font(.largeTitle)
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignTokens.ColorPalette.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }
}
