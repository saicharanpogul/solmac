import SwiftUI

enum EditorMode {
    case addProgram, editProgram
    case addAccount, editAccount

    var title: String {
        switch self {
        case .addProgram: "Add Program"
        case .editProgram: "Edit Program"
        case .addAccount: "Add Account"
        case .editAccount: "Edit Account"
        }
    }

    var isProgram: Bool {
        switch self {
        case .addProgram, .editProgram: true
        case .addAccount, .editAccount: false
        }
    }
}

struct ItemEditorSheet: View {
    let mode: EditorMode
    var onCancel: () -> Void

    @State private var address: String
    @State private var label: String
    @State private var cluster: ClusterSource
    @State private var isUpgradeable: Bool
    @State private var useMaybeClone: Bool

    // Auto-inspect state
    @State private var isInspecting = false
    @State private var inspectResult: InspectionResult?
    @State private var inspectError: String?
    @State private var addAssociatedAccounts = true

    private let programId: UUID
    private let accountId: UUID
    private var onSaveProgram: ((CloneableProgram, [(address: String, label: String)]) -> Void)?
    private var onSaveAccount: ((CloneableAccount) -> Void)?

    // Program initializer
    init(
        mode: EditorMode,
        program: CloneableProgram,
        onSave: @escaping (CloneableProgram, [(address: String, label: String)]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.onCancel = onCancel
        self.onSaveProgram = onSave
        self.onSaveAccount = nil
        self.programId = program.id
        self.accountId = UUID()
        _address = State(initialValue: program.address)
        _label = State(initialValue: program.label == program.address ? "" : program.label)
        _cluster = State(initialValue: program.cluster)
        _isUpgradeable = State(initialValue: program.isUpgradeable)
        _useMaybeClone = State(initialValue: false)
    }

    // Account initializer
    init(
        mode: EditorMode,
        account: CloneableAccount,
        onSaveAccount: @escaping (CloneableAccount) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.onCancel = onCancel
        self.onSaveProgram = nil
        self.onSaveAccount = onSaveAccount
        self.programId = UUID()
        self.accountId = account.id
        _address = State(initialValue: account.address)
        _label = State(initialValue: account.label == account.address ? "" : account.label)
        _cluster = State(initialValue: account.cluster)
        _isUpgradeable = State(initialValue: false)
        _useMaybeClone = State(initialValue: account.useMaybeClone)
    }

    private var isValid: Bool {
        let trimmed = address.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count >= 32 && trimmed.count <= 44
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(mode.title)
                .font(.headline)
                .padding()

            Form {
                TextField("Address", text: $address, prompt: Text("Base58 public key"))
                    .font(.system(.body, design: .monospaced))

                TextField("Label", text: $label, prompt: Text("Optional display name"))

                Picker("Cluster", selection: $cluster) {
                    ForEach(ClusterSource.allCases) { source in
                        Text(source.displayName).tag(source)
                    }
                }

                if mode.isProgram {
                    Toggle("Upgradeable program", isOn: $isUpgradeable)

                    // Auto-inspect button
                    HStack {
                        Button {
                            Task { await inspect() }
                        } label: {
                            if isInspecting {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Inspecting...")
                            } else {
                                Image(systemName: "magnifyingglass.circle")
                                Text("Auto-detect")
                            }
                        }
                        .disabled(!isValid || isInspecting)
                        .help("Inspect the program on-chain to detect upgradeability and find associated accounts")

                        if let result = inspectResult {
                            if result.isProgram {
                                Label("Valid program", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                Label("Not a program", systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        if let err = inspectError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    // Show detected associated accounts
                    if let result = inspectResult, !result.associatedAccounts.isEmpty {
                        Section("Detected Accounts") {
                            Toggle("Also add associated accounts", isOn: $addAssociatedAccounts)
                            ForEach(result.associatedAccounts, id: \.address) { acct in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(acct.label)
                                            .font(.caption)
                                        Text(acct.address)
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Toggle("Optional (skip if not found)", isOn: $useMaybeClone)
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal)

            Divider()

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 480, height: mode.isProgram ? 420 : 320)
    }

    private func inspect() async {
        isInspecting = true
        inspectError = nil
        inspectResult = nil

        let trimmed = address.trimmingCharacters(in: .whitespaces)
        let result = await ProgramInspector.inspect(
            address: trimmed,
            cluster: cluster
        )

        inspectResult = result
        isInspecting = false

        if result.isProgram {
            isUpgradeable = result.isUpgradeable
        } else {
            inspectError = "Address does not appear to be a program"
        }
    }

    private func save() {
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        let finalLabel = label.trimmingCharacters(in: .whitespaces)

        if mode.isProgram {
            let program = CloneableProgram(
                id: programId,
                address: trimmedAddress,
                label: finalLabel,
                cluster: cluster,
                isEnabled: true,
                isUpgradeable: isUpgradeable
            )
            let associated = (addAssociatedAccounts ? inspectResult?.associatedAccounts : nil) ?? []
            onSaveProgram?(program, associated)
        } else {
            let account = CloneableAccount(
                id: accountId,
                address: trimmedAddress,
                label: finalLabel,
                cluster: cluster,
                isEnabled: true,
                useMaybeClone: useMaybeClone
            )
            onSaveAccount?(account)
        }
    }
}
