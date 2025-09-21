import Foundation
import SwiftUI
import IRIXServices

public enum WorkspaceSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case editor = "Editor"
    case remoteHosts = "Remote Hosts"
    case buildLogs = "Build & Logs"
    case debugger = "Debugger"
    case settings = "Settings"

    public var id: String { rawValue }
}

@MainActor
public final class AppViewModel: ObservableObject {
    public struct Dependencies: Sendable {
        public var syncService: SyncService
        public var buildService: BuildService
        public var hostService: HostService
        public var analyticsService: AnalyticsService
        public var workspaceConfig: WorkspaceConfig
        public var requiresHostSetup: Bool
        public var configFileURL: URL?

        public init(syncService: SyncService, buildService: BuildService, hostService: HostService, analyticsService: AnalyticsService, workspaceConfig: WorkspaceConfig, requiresHostSetup: Bool, configFileURL: URL?) {
            self.syncService = syncService
            self.buildService = buildService
            self.hostService = hostService
            self.analyticsService = analyticsService
            self.workspaceConfig = workspaceConfig
            self.requiresHostSetup = requiresHostSetup
            self.configFileURL = configFileURL
        }
    }

    @Published public private(set) var selectedSection: WorkspaceSection = .dashboard
    @Published public private(set) var connectionState: ConnectionState = .connected
    @Published public private(set) var hosts: [IRIXServices.Host] = []
    @Published public private(set) var builds: [BuildSummary] = []
    @Published public private(set) var liveLogLines: [String] = []
    @Published public private(set) var latestError: String?
    @Published public var selectedHostID: IRIXServices.Host.ID?
    @Published public var shouldPromptHostSetup: Bool
    public let configFileURL: URL?

    private let dependencies: Dependencies
    private var hostRefreshTask: Task<Void, Never>?
    private var buildRefreshTask: Task<Void, Never>?

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.shouldPromptHostSetup = dependencies.requiresHostSetup
        self.configFileURL = dependencies.configFileURL
        Task { await self.bootstrap() }
    }

    deinit {
        hostRefreshTask?.cancel()
        buildRefreshTask?.cancel()
    }

    public func select(section: WorkspaceSection) {
        selectedSection = section
    }

    public func retry(host: IRIXServices.Host) {
        Task {
            await dependencies.hostService.retryConnection(for: host)
            let updatedHosts = await dependencies.hostService.loadHosts()
            await MainActor.run {
                self.updateHosts(updatedHosts)
            }
            dependencies.analyticsService.track(.connectionRetryStarted(hostId: host.id, attempt: 1, maxAttempts: 3))
        }
    }

    public func runBuild() {
        Task {
            do {
                let stream = try await dependencies.buildService.queueBuild(label: "Manual Build")
                await MainActor.run { self.liveLogLines.removeAll() }
                for await line in stream.lines {
                    await MainActor.run {
                        self.liveLogLines.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                let refreshedBuilds = await dependencies.buildService.loadRecentBuilds()
                await MainActor.run {
                    self.builds = refreshedBuilds
                }
            } catch {
                await MainActor.run {
                    self.latestError = error.localizedDescription
                }
            }
        }
    }

    private func bootstrap() async {
        do {
            try await dependencies.syncService.startMonitoring(for: dependencies.workspaceConfig)
        } catch {
            latestError = error.localizedDescription
            connectionState = .offline(reason: error.localizedDescription)
        }

        updateHosts(await dependencies.hostService.loadHosts())
        builds = await dependencies.buildService.loadRecentBuilds()

        let syncStream = dependencies.syncService.connectionState
        let analytics = dependencies.analyticsService
        Task {
            for await state in syncStream {
                await MainActor.run {
                    self.connectionState = state
                    if let hostId = self.hosts.first?.id {
                        analytics.track(.connectionStatusChanged(state, hostId: hostId))
                    }
                }
            }
        }

        startHostRefreshLoop()
        startBuildRefreshLoop()
    }

    private func startHostRefreshLoop() {
        hostRefreshTask?.cancel()
        let interval = max(5.0, dependencies.workspaceConfig.pollInterval)
        let hostService = dependencies.hostService
        hostRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                let refreshed = await hostService.loadHosts()
                await MainActor.run {
                    self.updateHosts(refreshed)
                }
            }
        }
    }

    private func startBuildRefreshLoop() {
        buildRefreshTask?.cancel()
        let buildService = dependencies.buildService
        buildRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                let refreshed = await buildService.loadRecentBuilds()
                await MainActor.run {
                    self.builds = refreshed
                }
            }
        }
    }

    private func updateHosts(_ refreshed: [IRIXServices.Host]) {
        hosts = refreshed
        guard !refreshed.isEmpty else {
            selectedHostID = nil
            shouldPromptHostSetup = true
            return
        }

        if let selectedHostID,
           refreshed.contains(where: { $0.id == selectedHostID }) {
            return
        }

        selectedHostID = refreshed.first?.id
        shouldPromptHostSetup = false
    }
}
