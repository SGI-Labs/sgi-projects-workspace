import Foundation

public actor SSHHostService: HostService {
    private struct HostSpec {
        let id: UUID
        let name: String
        let role: String
    }

    private struct HostCheckResult {
        let state: ConnectionState
        let success: Bool
    }

    private let config: WorkspaceConfig
    private let hostSpecs: [HostSpec]
    private var cachedHosts: [UUID: Host] = [:]

    public init(config: WorkspaceConfig, additionalHosts: [String]? = nil) {
        self.config = config
        let extras = additionalHosts ?? SSHHostService.readAdditionalHostSpecs()
        var specs: [HostSpec] = [HostSpec(id: UUID(), name: config.remoteHost, role: "Primary build")]
        for raw in extras {
            let parts = raw.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard let hostName = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines), !hostName.isEmpty else { continue }
            let role = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : "Secondary"
            specs.append(HostSpec(id: UUID(), name: hostName, role: role.isEmpty ? "Secondary" : role))
        }
        self.hostSpecs = specs
    }

    public func loadHosts() async -> [Host] {
        var results: [Host] = []
        for spec in hostSpecs {
            let check = checkHost(spec)
            let lastSync = check.success ? Date() : cachedHosts[spec.id]?.lastSync
            let host = Host(id: spec.id,
                            name: spec.name,
                            role: spec.role,
                            state: check.state,
                            lastSync: lastSync)
            cachedHosts[spec.id] = host
            results.append(host)
        }
        return results
    }

    public func retryConnection(for host: Host) async {
        guard let spec = hostSpecs.first(where: { $0.id == host.id }) else { return }
        let check = checkHost(spec)
        let lastSync = check.success ? Date() : cachedHosts[spec.id]?.lastSync
        cachedHosts[spec.id] = Host(id: spec.id,
                                    name: spec.name,
                                    role: spec.role,
                                    state: check.state,
                                    lastSync: lastSync)
    }

    private func checkHost(_ spec: HostSpec) -> HostCheckResult {
        let command = buildSSHCommand(for: spec.name)
        do {
            try ProcessRunner.run(command: command)
            return HostCheckResult(state: .connected, success: true)
        } catch {
            return HostCheckResult(state: .offline(reason: error.localizedDescription), success: false)
        }
    }

    private func buildSSHCommand(for host: String) -> [String] {
        var command: [String] = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=5"]
        if let identity = config.identityFile, !identity.isEmpty {
            command.append(contentsOf: ["-i", expandTilde(identity)])
        }
        command.append("\(config.remoteUser)@\(host)")
        command.append("echo alive")
        return command
    }

    private func expandTilde(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    private static func readAdditionalHostSpecs() -> [String] {
        guard let raw = ProcessInfo.processInfo.environment["IRIX_IDE_ADDITIONAL_HOSTS"], !raw.isEmpty else {
            return []
        }
        return raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
}
