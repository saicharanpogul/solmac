import SwiftUI

struct SettingsProgramsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var editingProgram: CloneableProgram?
    @State private var showingEditor = false
    @State private var isAddingNew = false

    var body: some View {
        VStack(spacing: 0) {
            if configManager.config.programs.isEmpty {
                ContentUnavailableView(
                    "No Programs",
                    systemImage: "cpu",
                    description: Text("Add programs to clone into your local validator.")
                )
            } else {
                List {
                    ForEach(configManager.config.programs) { program in
                        HStack {
                            Toggle("", isOn: programBinding(for: program.id))
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(program.label)
                                    .fontWeight(.medium)
                                HStack(spacing: 4) {
                                    Text(program.address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    ClusterBadge(cluster: program.cluster)
                                    if program.isUpgradeable {
                                        Text("Upgradeable")
                                            .font(.caption2)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(.blue.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }

                            Spacer()

                            Button { editProgram(program) } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button { configManager.removeProgram(id: program.id) } label: {
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
                Button("Add Program") {
                    isAddingNew = true
                    editingProgram = CloneableProgram(address: "")
                    showingEditor = true
                }
                .padding(8)
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let program = editingProgram {
                ItemEditorSheet(
                    mode: isAddingNew ? .addProgram : .editProgram,
                    program: program,
                    onSave: { saved in
                        if isAddingNew {
                            configManager.addProgram(saved)
                        } else {
                            configManager.updateProgram(saved)
                        }
                        showingEditor = false
                    },
                    onCancel: { showingEditor = false }
                )
            }
        }
    }

    private func editProgram(_ program: CloneableProgram) {
        isAddingNew = false
        editingProgram = program
        showingEditor = true
    }

    private func programBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { configManager.config.programs.first(where: { $0.id == id })?.isEnabled ?? false },
            set: { newValue in
                if var p = configManager.config.programs.first(where: { $0.id == id }) {
                    p.isEnabled = newValue
                    configManager.updateProgram(p)
                }
            }
        )
    }
}

struct ClusterBadge: View {
    let cluster: ClusterSource

    var body: some View {
        Text(cluster.displayName)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch cluster {
        case .mainnetBeta: .green
        case .devnet: .purple
        case .testnet: .orange
        }
    }
}
