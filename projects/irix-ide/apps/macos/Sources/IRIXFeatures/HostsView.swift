import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct HostsView: View {
    let hosts: [IRIXServices.Host]
    let retryHandler: (IRIXServices.Host) -> Void

    public init(hosts: [IRIXServices.Host], retryHandler: @escaping (IRIXServices.Host) -> Void) {
        self.hosts = hosts
        self.retryHandler = retryHandler
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Remote Hosts")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)

            Table(hosts) {
                TableColumn("Host") { host in
                    Text(host.name)
                }
                TableColumn("Role") { host in
                    Text(host.role)
                }
                TableColumn("Status") { host in
                    StatusBadge(state: host.state)
                }
                TableColumn("Actions") { host in
                    Button("Retry") {
                        retryHandler(host)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canRetry(host.state))
                }
            }
            .frame(maxHeight: 400)
        }
        .padding(DesignTokens.Spacing.xl)
        .background(DesignTokens.ColorPalette.backgroundSurface)
    }

    private func canRetry(_ state: ConnectionState) -> Bool {
        switch state {
        case .degraded, .offline:
            return true
        default:
            return false
        }
    }
}
