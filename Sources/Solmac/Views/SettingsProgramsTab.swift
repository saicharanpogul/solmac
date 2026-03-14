import SwiftUI

/// Wrapper to distinguish add vs edit in `.sheet(item:)`
struct ProgramEditItem: Identifiable {
    let id = UUID()
    let program: CloneableProgram
    let isNew: Bool
}

struct SettingsProgramsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var editItem: ProgramEditItem?
    @State private var isFetchingAll = false

    var body: some View {
        VStack(spacing: 0) {
            if configManager.config.programs.isEmpty {
                ContentUnavailableView(
                    "No Programs",
                    systemImage: "cpu",
                    description: Text("Add programs from the Presets tab or manually.")
                )
            } else {
                List {
                    ForEach(configManager.config.programs) { program in
                        ProgramRow(
                            program: program,
                            onToggle: { @MainActor enabled in
                                var p = program
                                p.isEnabled = enabled
                                configManager.updateProgram(p)
                            },
                            onEdit: {
                                editItem = ProgramEditItem(program: program, isNew: false)
                            },
                            onDelete: {
                                configManager.removeProgram(id: program.id)
                            }
                        )
                    }
                }
            }

            Divider()

            HStack {
                Button {
                    Task { await fetchAllLatest() }
                } label: {
                    if isFetchingAll {
                        ProgressView()
                            .controlSize(.small)
                        Text("Fetching...")
                    } else {
                        Image(systemName: "arrow.clockwise")
                        Text("Fetch Latest")
                    }
                }
                .controlSize(.small)
                .disabled(isFetchingAll || configManager.config.programs.isEmpty)
                .help("Re-fetch all enabled programs from their respective clusters to update the local cache")

                Spacer()

                Button("Add Program") {
                    editItem = ProgramEditItem(
                        program: CloneableProgram(address: ""),
                        isNew: true
                    )
                }
                .controlSize(.small)
            }
            .padding(8)
        }
        .sheet(item: $editItem) { item in
            ItemEditorSheet(
                mode: item.isNew ? .addProgram : .editProgram,
                program: item.program,
                onSave: { saved, associatedAccounts in
                    if item.isNew {
                        configManager.addProgram(saved)
                    } else {
                        configManager.updateProgram(saved)
                    }
                    for acct in associatedAccounts {
                        if !configManager.config.accounts.contains(where: { $0.address == acct.address }) {
                            configManager.addAccount(CloneableAccount(
                                address: acct.address,
                                label: acct.label,
                                cluster: saved.cluster,
                                isEnabled: true,
                                useMaybeClone: true
                            ))
                        }
                    }
                    editItem = nil
                },
                onCancel: { editItem = nil }
            )
        }
    }

    private func fetchAllLatest() async {
        isFetchingAll = true
        let enabledPrograms = configManager.config.programs.filter(\.isEnabled)

        for program in enabledPrograms {
            let result = await ProgramInspector.inspect(
                address: program.address,
                cluster: program.cluster
            )
            if result.isProgram && result.isUpgradeable != program.isUpgradeable {
                var updated = program
                updated.isUpgradeable = result.isUpgradeable
                configManager.updateProgram(updated)
            }
            // Add any newly discovered associated accounts
            for acct in result.associatedAccounts {
                if !configManager.config.accounts.contains(where: { $0.address == acct.address }) {
                    configManager.addAccount(CloneableAccount(
                        address: acct.address,
                        label: acct.label,
                        cluster: program.cluster,
                        isEnabled: true,
                        useMaybeClone: true
                    ))
                }
            }
        }
        isFetchingAll = false
    }
}

struct ProgramRow: View {
    let program: CloneableProgram
    let onToggle: @MainActor @Sendable (Bool) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { program.isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)

            VStack(alignment: .leading, spacing: 2) {
                Text(program.label)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    Text(program.address)
                        .font(.system(.caption, design: .monospaced))
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
