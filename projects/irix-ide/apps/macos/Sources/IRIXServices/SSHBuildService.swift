import Foundation

public struct LiveBuildLogStream: BuildLogStream {
    public let lines: AsyncStream<String>
    fileprivate let continuation: AsyncStream<String>.Continuation
}

extension LiveBuildLogStream: @unchecked Sendable {}

public actor SSHBuildService: BuildService {
    private let config: WorkspaceConfig
    private var runningTasks: [UUID: Task<Void, Never>] = [:]

    public init(config: WorkspaceConfig) {
        self.config = config
    }

    public func queueBuild(label: String) async throws -> BuildLogStream {
        let stream = AsyncStream<String>.makeStream(bufferingPolicy: .unbounded)
        stream.continuation.yield("[build] Starting build: \(label)")

        let command = buildSSHCommand()
        let workingDirectory = config.projectPath
        let buildID = UUID()
        let task = Task.detached { @Sendable in
            do {
                let lineStream = try ProcessRunner.streamLines(command: command, workingDirectory: workingDirectory)
                for try await line in lineStream {
                    stream.continuation.yield(line)
                }
                stream.continuation.yield("[build] Completed successfully")
            } catch {
                stream.continuation.yield("[build] Failed: \(error.localizedDescription)")
            }
            stream.continuation.finish()
        }

        runningTasks[buildID] = task
        Task { [buildID] in
            _ = await task.value
            await self.finishTask(id: buildID)
        }

        return LiveBuildLogStream(lines: stream.stream, continuation: stream.continuation)
    }

    public func loadRecentBuilds() async -> [BuildSummary] {
        [
            BuildSummary(label: "Latest build", status: .succeeded, hostName: config.remoteHost, startedAt: Date().addingTimeInterval(-300), duration: 28, triggeredBy: config.remoteUser)
        ]
    }

    private func buildSSHCommand() -> [String] {
        var command: [String] = ["ssh"]
        if let identity = config.identityFile {
            command.append(contentsOf: ["-i", expandTilde(identity)])
        }
        command.append("\(config.remoteUser)@\(config.remoteHost)")
        let remoteCommand = "cd \(config.remotePath) && \(config.buildCommands.joined(separator: " && "))"
        command.append(remoteCommand)
        return command
    }

    private func finishTask(id: UUID) async {
        runningTasks[id] = nil
    }

    private func expandTilde(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }
}
