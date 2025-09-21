import SwiftUI
import IRIXDesignSystem
import IRIXFeatures
import IRIXServices

@main
struct IRIXIDEApp: App {
    @StateObject private var viewModel: AppViewModel

    init() {
        let configuration = AppConfiguration.load()
        let syncService: SyncService = configuration.syncService
        let buildService: BuildService = configuration.buildService
        let hostService: HostService = configuration.hostService
        let analytics = ConsoleAnalyticsService()

        let dependencies = AppViewModel.Dependencies(
            syncService: syncService,
            buildService: buildService,
            hostService: hostService,
            analyticsService: analytics,
            workspaceConfig: configuration.workspaceConfig,
            requiresHostSetup: configuration.requiresHostSetup,
            configFileURL: configuration.configFileURL
        )
        _viewModel = StateObject(wrappedValue: AppViewModel(dependencies: dependencies))
    }

    var body: some Scene {
        WindowGroup {
            MainAppView(viewModel: viewModel)
                .frame(minWidth: 1080, minHeight: 720)
                .background(DesignTokens.ColorPalette.backgroundBase)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

private struct AppConfiguration {
    let workspaceConfig: WorkspaceConfig
    let syncService: SyncService
    let buildService: BuildService
    let hostService: HostService
    let requiresHostSetup: Bool
    let configFileURL: URL

    static func load() -> AppConfiguration {
        let environment = ProcessInfo.processInfo.environment
        let configPath = environment["IRIX_IDE_CONFIG"]

        let baseURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let defaultCandidates = [
            configPath.flatMap { URL(fileURLWithPath: $0, isDirectory: false) },
            baseURL.appendingPathComponent("config.yml"),
            baseURL.appendingPathComponent("../tools/prototype/edit-build-loop/config.sample.yml"),
            baseURL.appendingPathComponent("../../tools/prototype/edit-build-loop/config.sample.yml")
        ].compactMap { $0 }

        let configuration: WorkspaceConfig
        var initialState: ConnectionState = .connected
        var requiresHostSetup = false
        var configURLUsed = baseURL.appendingPathComponent("config.yml")
        if let url = defaultCandidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }),
           let loaded = try? ConfigLoader.load(from: url) {
            configuration = loaded
            configURLUsed = url
            if loaded.remoteHost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                requiresHostSetup = true
                initialState = .offline(reason: "No remote host configured")
            }
        } else {
            let fallbackProject = baseURL
            configuration = WorkspaceConfig(
                projectPath: fallbackProject,
                remoteHost: "octane",
                remoteUser: NSUserName(),
                remotePath: "~/irix",
                identityFile: nil,
                pollInterval: 5,
                buildCommands: ["echo 'No build command configured'"]
            )
            initialState = .offline(reason: "Using fallback configuration")
            requiresHostSetup = true
        }

        let syncService = RsyncSyncService(initialState: initialState)
        let buildService = SSHBuildService(config: configuration)
        let hostService = SSHHostService(config: configuration)

        return AppConfiguration(
            workspaceConfig: configuration,
            syncService: syncService,
            buildService: buildService,
            hostService: hostService,
            requiresHostSetup: requiresHostSetup,
            configFileURL: configURLUsed
        )
    }
}
