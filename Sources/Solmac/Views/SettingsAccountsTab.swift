import SwiftUI

struct SettingsAccountsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var editingAccount: CloneableAccount?
    @State private var showingEditor = false
    @State private var isAddingNew = false

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
                        HStack {
                            Toggle("", isOn: accountBinding(for: account.id))
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.label)
                                    .fontWeight(.medium)
                                HStack(spacing: 4) {
                                    Text(account.address)
                                        .font(.caption)
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

                            Button { editAccount(account) } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button { configManager.removeAccount(id: account.id) } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Add Account") {
                    isAddingNew = true
                    editingAccount = CloneableAccount(address: "")
                    showingEditor = true
                }
                .padding(8)
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let account = editingAccount {
                ItemEditorSheet(
                    mode: isAddingNew ? .addAccount : .editAccount,
                    account: account,
                    onSaveAccount: { saved in
                        if isAddingNew {
                            configManager.addAccount(saved)
                        } else {
                            configManager.updateAccount(saved)
                        }
                        showingEditor = false
                    },
                    onCancel: { showingEditor = false }
                )
            }
        }
    }

    private func editAccount(_ account: CloneableAccount) {
        isAddingNew = false
        editingAccount = account
        showingEditor = true
    }

    private func accountBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { configManager.config.accounts.first(where: { $0.id == id })?.isEnabled ?? false },
            set: { newValue in
                if var a = configManager.config.accounts.first(where: { $0.id == id }) {
                    a.isEnabled = newValue
                    configManager.updateAccount(a)
                }
            }
        )
    }
}
