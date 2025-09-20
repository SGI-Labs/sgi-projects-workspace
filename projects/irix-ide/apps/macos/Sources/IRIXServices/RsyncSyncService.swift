import Foundation

public actor RsyncSyncService: SyncService {
    private let remoteRsyncPath = "/usr/nekoware/bin/rsync"

    private var streamContinuation: AsyncStream<ConnectionState>.Continuation?
    public let connectionState: AsyncStream<ConnectionState>
    private var monitorTask: Task<Void, Never>?
    private var currentConfig: WorkspaceConfig?

    public init(initialState: ConnectionState = .connected) {
        let stream = AsyncStream<ConnectionState>.makeStream()
        self.connectionState = stream.stream
        self.streamContinuation = stream.continuation
        stream.continuation.yield(initialState)
    }

    deinit {
        streamContinuation?.finish()
    }

    public func startMonitoring(for config: WorkspaceConfig) async throws {
        currentConfig = config
        await yieldState(.reconnecting(attempt: 1, maxAttempts: 3))

        do {
            try await runSync(config: config)
            await yieldState(.connected)
        } catch {
            await yieldState(.offline(reason: error.localizedDescription))
        }

        monitorTask?.cancel()
        monitorTask = Task { [config] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: UInt64(config.pollInterval * 1_000_000_000))
                    try await self.runSync(config: config)
                    await self.yieldState(.connected)
                } catch is CancellationError {
                    break
                } catch {
                    await self.yieldState(.offline(reason: error.localizedDescription))
                }
            }
        }
    }

    public func stopMonitoring() async {
        monitorTask?.cancel()
        monitorTask = nil
        await yieldState(.offline(reason: "Stopped"))
    }

    private func runSync(config: WorkspaceConfig) async throws {
        let rsyncArguments = buildRsyncCommand(for: config)
        let _ = try await Task.detached { @Sendable in
            try ProcessRunner.run(command: rsyncArguments, workingDirectory: config.projectPath)
        }.value
    }

    private func buildRsyncCommand(for config: WorkspaceConfig) -> [String] {
        var command: [String] = ["rsync", "--rsync-path", remoteRsyncPath, "-r", "-t", "--delete"]
        if let identity = config.identityFile {
            command.append("-e")
            command.append("ssh -i \(expandTilde(identity))")
        }
        let localPath = config.projectPath.path
        let normalized = localPath.hasSuffix("/") ? localPath : localPath + "/"
        command.append(normalized)
        command.append(config.remoteTarget)
        return command
    }

    private func expandTilde(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    private func yieldState(_ state: ConnectionState) async {
        streamContinuation?.yield(state)
    }
}
