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

        public init(syncService: SyncService, buildService: BuildService, hostService: HostService, analyticsService: AnalyticsService, workspaceConfig: WorkspaceConfig) {
            self.syncService = syncService
            self.buildService = buildService
            self.hostService = hostService
            self.analyticsService = analyticsService
            self.workspaceConfig = workspaceConfig
        }
    }

    @Published public private(set) var selectedSection: WorkspaceSection = .dashboard
    @Published public private(set) var connectionState: ConnectionState = .connected
    @Published public private(set) var hosts: [IRIXServices.Host] = []
    @Published public private(set) var builds: [BuildSummary] = []
    @Published public private(set) var liveLogLines: [String] = []
    @Published public private(set) var latestError: String?

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        Task { await self.bootstrap() }
    }

    public func select(section: WorkspaceSection) {
        selectedSection = section
    }

    public func retry(host: IRIXServices.Host) {
        Task {
            await dependencies.hostService.retryConnection(for: host)
            let updatedHosts = await dependencies.hostService.loadHosts()
            await MainActor.run {
                self.hosts = updatedHosts
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

        hosts = await dependencies.hostService.loadHosts()
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
    }
}
