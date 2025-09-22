import Foundation

public protocol SyncService: AnyObject, Sendable {
    var connectionState: AsyncStream<ConnectionState> { get }
    func startMonitoring(for config: WorkspaceConfig) async throws
    func stopMonitoring() async
}

public actor StubSyncService: SyncService {
    private var stateContinuation: AsyncStream<ConnectionState>.Continuation?
    public let connectionState: AsyncStream<ConnectionState>

    public init(initialState: ConnectionState = .connected) {
        let stream = AsyncStream<ConnectionState>.makeStream()
        stream.continuation.yield(initialState)
        self.connectionState = stream.stream
        self.stateContinuation = stream.continuation
    }

    public func startMonitoring(for config: WorkspaceConfig) async throws {
        // TODO: Replace with real filesystem watcher & rsync bridge
    }

    public func stopMonitoring() async {
        stateContinuation?.finish()
    }
}
