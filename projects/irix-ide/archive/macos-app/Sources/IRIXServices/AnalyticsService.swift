import Foundation

public enum AnalyticsEvent {
    case connectionStatusChanged(ConnectionState, hostId: UUID)
    case connectionRetryStarted(hostId: UUID, attempt: Int, maxAttempts: Int)
    case connectionRetryFinished(hostId: UUID, attempt: Int, success: Bool)
    case offlineQueueUpdated(count: Int)
    case offlineActionSelected(action: String)
    case deployConfirmationShown
    case deployConfirmationCompleted(confirmed: Bool)
    case undoToastAction(action: String)
    case logsReconnectClicked(hostId: UUID)
}

public protocol AnalyticsService: AnyObject, Sendable {
    func track(_ event: AnalyticsEvent)
}

public final class ConsoleAnalyticsService: AnalyticsService, @unchecked Sendable {
    public init() {}

    public func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics]", event)
        #endif
    }
}
