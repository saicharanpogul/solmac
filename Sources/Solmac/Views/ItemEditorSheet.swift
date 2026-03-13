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

    private let programId: UUID
    private let accountId: UUID
    private var onSaveProgram: ((CloneableProgram) -> Void)?
    private var onSaveAccount: ((CloneableAccount) -> Void)?

    // Program initializer
    init(
        mode: EditorMode,
        program: CloneableProgram,
        onSave: @escaping (CloneableProgram) -> Void,
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
        !address.trimmingCharacters(in: .whitespaces).isEmpty
            && address.count >= 32
            && address.count <= 44
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
        .frame(width: 450)
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
            onSaveProgram?(program)
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
