import Foundation

public protocol HostService: Sendable {
    func loadHosts() async -> [Host]
    func retryConnection(for host: Host) async
}

public actor StubHostService: HostService {
    private var hosts: [Host]

    public init(config: WorkspaceConfig? = nil) {
        if let config {
            hosts = [
                Host(name: config.remoteHost, role: "Primary build", state: .connected, lastSync: Date()),
                Host(name: "standby", role: "Backup", state: .degraded, lastSync: Date().addingTimeInterval(-300))
            ]
        } else {
            hosts = [
                Host(name: "octane", role: "Primary build", state: .connected, lastSync: Date().addingTimeInterval(-60)),
                Host(name: "indigo2", role: "Debug staging", state: .degraded, lastSync: Date().addingTimeInterval(-300)),
                Host(name: "onyx2", role: "Perf lab", state: .offline(reason: "Maintenance"), lastSync: nil)
            ]
        }
    }

    public func loadHosts() async -> [Host] {
        hosts
    }

    public func retryConnection(for host: Host) async {
        guard let index = hosts.firstIndex(where: { $0.id == host.id }) else { return }
        hosts[index].state = .reconnecting(attempt: 1, maxAttempts: 3)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        hosts[index].state = .connected
    }
}
