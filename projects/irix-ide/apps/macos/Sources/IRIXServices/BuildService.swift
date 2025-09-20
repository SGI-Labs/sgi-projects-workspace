import Foundation

public protocol BuildLogStream: Sendable {
    var lines: AsyncStream<String> { get }
}

public protocol BuildService: Sendable {
    func queueBuild(label: String) async throws -> BuildLogStream
    func loadRecentBuilds() async -> [BuildSummary]
}

public actor StubBuildService: BuildService {
    private var builds: [BuildSummary] = [
        BuildSummary(label: "Build #105 • octane", status: .running, startedAt: Date().addingTimeInterval(-45), duration: nil),
        BuildSummary(label: "Build #104 • indigo2", status: .queued, startedAt: Date(), duration: nil),
        BuildSummary(label: "Build #103 • octane", status: .succeeded, startedAt: Date().addingTimeInterval(-360), duration: 28)
    ]

    public init() {}

    public func queueBuild(label: String) async throws -> BuildLogStream {
        let stream = StubBuildStream()
        stream.append("Queuing build: \(label)")
        stream.append("Collecting files for rsync …")
        stream.append("Running remote command: cc -o bin/hello src/hello.c")
        stream.append("Build succeeded")
        stream.finish()
        return stream
    }

    public func loadRecentBuilds() async -> [BuildSummary] {
        builds
    }
}

final class StubBuildStream: BuildLogStream {
    private let continuation: AsyncStream<String>.Continuation
    let lines: AsyncStream<String>

    init() {
        var continuation: AsyncStream<String>.Continuation!
        lines = AsyncStream { cont in continuation = cont }
        self.continuation = continuation
    }

    func append(_ line: String) {
        continuation.yield(line)
    }

    func finish() {
        continuation.finish()
    }
}
