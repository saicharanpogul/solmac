import SwiftUI

struct AccountEditItem: Identifiable {
    let id = UUID()
    let account: CloneableAccount
    let isNew: Bool
}

struct SettingsAccountsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var editItem: AccountEditItem?
    @State private var deleteTarget: CloneableAccount?
    @State private var searchText = ""

    private var filteredAccounts: [CloneableAccount] {
        guard !searchText.isEmpty else { return configManager.config.accounts }
        return configManager.config.accounts.filter {
            $0.label.localizedCaseInsensitiveContains(searchText)
                || $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var enabledCount: Int {
        configManager.config.accounts.filter(\.isEnabled).count
    }

    var body: some View {
        VStack(spacing: 0) {
            if configManager.config.accounts.isEmpty {
                ContentUnavailableView(
                    "No Accounts",
                    systemImage: "wallet.bifold",
                    description: Text("Add accounts to clone into your local validator.")
                )
            } else {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search accounts...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                List {
                    ForEach(filteredAccounts) { account in
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
                                deleteTarget = account
                            },
                            onCopyAddress: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(account.address, forType: .string)
                            }
                        )
                    }
                    .onMove { source, destination in
                        configManager.moveAccounts(from: source, to: destination)
                    }
                }
            }

            Divider()

            HStack {
                if !configManager.config.accounts.isEmpty {
                    Text("\(enabledCount)/\(configManager.config.accounts.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("All") {
                        for account in configManager.config.accounts where !account.isEnabled {
                            var a = account
                            a.isEnabled = true
                            configManager.updateAccount(a)
                        }
                    }
                    .controlSize(.small)
                    .disabled(enabledCount == configManager.config.accounts.count)

                    Button("None") {
                        for account in configManager.config.accounts where account.isEnabled {
                            var a = account
                            a.isEnabled = false
                            configManager.updateAccount(a)
                        }
                    }
                    .controlSize(.small)
                    .disabled(enabledCount == 0)
                }

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
        .alert("Delete Account", isPresented: Binding(
            get: { deleteTarget != nil },
            set: { if !$0 { deleteTarget = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let target = deleteTarget {
                    configManager.removeAccount(id: target.id)
                }
                deleteTarget = nil
            }
            Button("Cancel", role: .cancel) {
                deleteTarget = nil
            }
        } message: {
            if let target = deleteTarget {
                Text("Are you sure you want to delete \"\(target.label)\"?")
            }
        }
    }
}

struct AccountRow: View {
    let account: CloneableAccount
    let onToggle: @MainActor @Sendable (Bool) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onCopyAddress: (() -> Void)? = nil

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
                        .onTapGesture { onCopyAddress?() }
                        .help("Click to copy address")
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
