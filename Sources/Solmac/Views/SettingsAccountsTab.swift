import SwiftUI

struct AccountEditItem: Identifiable {
    let id = UUID()
    let account: CloneableAccount
    let isNew: Bool
}

struct SettingsAccountsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var editItem: AccountEditItem?

    var body: some View {
        VStack(spacing: 0) {
            if configManager.config.accounts.isEmpty {
                ContentUnavailableView(
                    "No Accounts",
                    systemImage: "wallet.bifold",
                    description: Text("Add accounts to clone into your local validator.")
                )
            } else {
                List {
                    ForEach(configManager.config.accounts) { account in
                        AccountRow(
                            account: account,
                            onToggle: { @MainActor enabled in
                                var a = account
                                a.isEnabled = enabled
                                configManager.updateAccount(a)
                            },
                            onEdit: {
                                editItem = AccountEditItem(account: account, isNew: false)
                            },
                            onDelete: {
                                configManager.removeAccount(id: account.id)
                            }
                        )
                    }
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Add Account") {
                    editItem = AccountEditItem(
                        account: CloneableAccount(address: ""),
                        isNew: true
                    )
                }
                .controlSize(.small)
            }
            .padding(8)
        }
        .sheet(item: $editItem) { item in
            ItemEditorSheet(
                mode: item.isNew ? .addAccount : .editAccount,
                account: item.account,
                onSaveAccount: { saved in
                    if item.isNew {
                        configManager.addAccount(saved)
                    } else {
                        configManager.updateAccount(saved)
                    }
                    editItem = nil
                },
                onCancel: { editItem = nil }
            )
        }
    }
}

struct AccountRow: View {
    let account: CloneableAccount
    let onToggle: @MainActor @Sendable (Bool) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { account.isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.label)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    Text(account.address)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    ClusterBadge(cluster: account.cluster)
                    if account.useMaybeClone {
                        Text("Optional")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.yellow.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 2)
    }
}
