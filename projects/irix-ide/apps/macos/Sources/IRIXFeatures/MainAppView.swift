import SwiftUI
import AppKit
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
            StatusBarView(connectionState: viewModel.connectionState, latestBuild: viewModel.builds.first)
                    .padding(DesignTokens.Spacing.md)
        }
        .background(DesignTokens.ColorPalette.backgroundBase)
        .sheet(isPresented: $viewModel.shouldPromptHostSetup) {
            HostSetupPrompt(configFileURL: viewModel.configFileURL)
        }
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
            HostsView(hosts: viewModel.hosts, selectedHostID: $viewModel.selectedHostID) { host in
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

private struct HostSetupPrompt: View {
    let configFileURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Configure IRIX Host")
                .font(.title.weight(.semibold))
            Text("We couldn't find a valid remote host configuration. Update your `config.yml` (or set `IRIX_IDE_CONFIG`) to point at an accessible IRIX machine, then relaunch the app.")
                .foregroundColor(DesignTokens.ColorPalette.textMuted)
            if let url = configFileURL {
                Text("Current config: \(url.path)")
                    .font(.footnote)
                    .foregroundColor(DesignTokens.ColorPalette.textMuted)
            }
            HStack {
                Button("Open Config File") {
                    openConfigFile()
                }
                .buttonStyle(.borderedProminent)

                Button("View Setup Guide") {
                    if let docsURL = URL(string: "https://github.com/SGI-Labs/sgi-projects-workspace/blob/main/projects/irix-ide/docs/prd.md#core-workflows") {
                        NSWorkspace.shared.open(docsURL)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(minWidth: 420)
    }

    private func openConfigFile() {
        guard let url = configFileURL else { return }
        let manager = FileManager.default
        if !manager.fileExists(atPath: url.path) {
            let projectPath = url.deletingLastPathComponent().path
            let template = "# IRIX IDE configuration\nproject_path: \(projectPath)\nremote_host: \nremote_user: \(NSUserName())\nremote_path: ~/irix\nidentity_file: \npoll_interval: 5\nbuild_commands:\n  - echo 'Add build commands here'\n"
            try? template.write(to: url, atomically: true, encoding: .utf8)
        }
        NSWorkspace.shared.open(url)
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
