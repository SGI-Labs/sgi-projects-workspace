import SwiftUI
import IRIXServices
import IRIXDesignSystem

public struct HostsView: View {
    let hosts: [IRIXServices.Host]
    @Binding var selectedHostID: IRIXServices.Host.ID?
    let retryHandler: (IRIXServices.Host) -> Void

    public init(hosts: [IRIXServices.Host], selectedHostID: Binding<IRIXServices.Host.ID?>, retryHandler: @escaping (IRIXServices.Host) -> Void) {
        self.hosts = hosts
        self._selectedHostID = selectedHostID
        self.retryHandler = retryHandler
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Remote Hosts")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)

            Table(hosts, selection: $selectedHostID) {
                TableColumn("Host") { host in
                    Text(host.name)
                }
                TableColumn("Role") { host in
                    Text(host.role)
                }
                TableColumn("Status") { host in
                    StatusBadge(state: host.state)
                }
                TableColumn("Last Sync") { host in
                    Text(lastSyncLabel(for: host))
                        .foregroundColor(DesignTokens.ColorPalette.textMuted)
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

            if let selectedHost = hosts.first(where: { $0.id == selectedHostID }) {
                HostDetailCard(host: selectedHost, retryHandler: retryHandler)
            } else {
                PlaceholderCard(title: "Select a host", message: "Choose a host from the table to inspect connection details.")
            }
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

    private func lastSyncLabel(for host: IRIXServices.Host) -> String {
        guard let lastSync = host.lastSync else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastSync, relativeTo: Date())
    }
}

private struct HostDetailCard: View {
    let host: IRIXServices.Host
    let retryHandler: (IRIXServices.Host) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(host.name)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(DesignTokens.ColorPalette.textPrimary)
                    Text(host.role)
                        .foregroundColor(DesignTokens.ColorPalette.textMuted)
                }
                Spacer()
                StatusBadge(state: host.state)
            }

            if case let .offline(reason) = host.state, let reason, !reason.isEmpty {
                Text("Last error: \(reason)")
                    .foregroundColor(DesignTokens.ColorPalette.danger)
                    .font(.footnote)
            }

            if let lastSync = host.lastSync {
                Text("Last sync: \(formatRelative(lastSync))")
                    .foregroundColor(DesignTokens.ColorPalette.textMuted)
            }

            HStack {
                Spacer()
                Button("Retry Connection") {
                    retryHandler(host)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canRetry(host.state))
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DesignTokens.ColorPalette.backgroundPanel)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
    }

    private func canRetry(_ state: ConnectionState) -> Bool {
        switch state {
        case .degraded, .offline:
            return true
        default:
            return false
        }
    }

    private func formatRelative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private struct PlaceholderCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.headline)
                .foregroundColor(DesignTokens.ColorPalette.textPrimary)
            Text(message)
                .foregroundColor(DesignTokens.ColorPalette.textMuted)
        }

        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DesignTokens.ColorPalette.backgroundPanel)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium, style: .continuous))
    }
}
