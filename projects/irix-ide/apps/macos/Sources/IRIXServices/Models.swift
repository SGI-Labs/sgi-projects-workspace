import Foundation

public enum ConnectionState: Equatable, Sendable {
    case connected
    case degraded
    case reconnecting(attempt: Int, maxAttempts: Int)
    case offline(reason: String?)
}

public struct Host: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var role: String
    public var state: ConnectionState
    public var lastSync: Date?

    public init(id: UUID = UUID(), name: String, role: String, state: ConnectionState, lastSync: Date?) {
        self.id = id
        self.name = name
        self.role = role
        self.state = state
        self.lastSync = lastSync
    }
}

public struct BuildSummary: Identifiable, Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        case queued
        case running
        case succeeded
        case failed
    }

    public let id: UUID
    public var label: String
    public var status: Status
    public var startedAt: Date
    public var duration: TimeInterval?

    public init(id: UUID = UUID(), label: String, status: Status, startedAt: Date, duration: TimeInterval?) {
        self.id = id
        self.label = label
        self.status = status
        self.startedAt = startedAt
        self.duration = duration
    }
}

public struct WorkspaceConfig: Equatable, Sendable {
    public var projectPath: URL
    public var remoteHost: String
    public var remoteUser: String
    public var remotePath: String
    public var identityFile: String?
    public var pollInterval: TimeInterval
    public var buildCommands: [String]

    public init(projectPath: URL, remoteHost: String, remoteUser: String, remotePath: String, identityFile: String?, pollInterval: TimeInterval, buildCommands: [String]) {
        self.projectPath = projectPath
        self.remoteHost = remoteHost
        self.remoteUser = remoteUser
        self.remotePath = remotePath
        self.identityFile = identityFile
        self.pollInterval = pollInterval
        self.buildCommands = buildCommands
    }

    public var remoteTarget: String {
        "\(remoteUser)@\(remoteHost):\(remotePath)"
    }
}
