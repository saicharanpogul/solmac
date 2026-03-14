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
    @State private var fetchingProgramId: UUID?
    @State private var deleteTarget: CloneableProgram?
    @State private var searchText = ""

    private var filteredPrograms: [CloneableProgram] {
        guard !searchText.isEmpty else { return configManager.config.programs }
        return configManager.config.programs.filter {
            $0.label.localizedCaseInsensitiveContains(searchText)
                || $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var enabledCount: Int {
        configManager.config.programs.filter(\.isEnabled).count
    }

    var body: some View {
        VStack(spacing: 0) {
            if configManager.config.programs.isEmpty {
                ContentUnavailableView(
                    "No Programs",
                    systemImage: "cpu",
                    description: Text("Add programs from the Presets tab or manually.")
                )
            } else {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search programs...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                List {
                    ForEach(filteredPrograms) { program in
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
                                deleteTarget = program
                            },
                            onFetch: {
                                Task { await fetchProgram(program) }
                            },
                            onCopyAddress: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(program.address, forType: .string)
                            },
                            isFetching: fetchingProgramId == program.id
                        )
                    }
                    .onMove { source, destination in
                        configManager.movePrograms(from: source, to: destination)
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
                .help("Re-fetch all enabled programs from their respective clusters")

                if !configManager.config.programs.isEmpty {
                    Text("\(enabledCount)/\(configManager.config.programs.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("All") {
                        for program in configManager.config.programs where !program.isEnabled {
                            var p = program
                            p.isEnabled = true
                            configManager.updateProgram(p)
                        }
                    }
                    .controlSize(.small)
                    .disabled(enabledCount == configManager.config.programs.count)

                    Button("None") {
                        for program in configManager.config.programs where program.isEnabled {
                            var p = program
                            p.isEnabled = false
                            configManager.updateProgram(p)
                        }
                    }
                    .controlSize(.small)
                    .disabled(enabledCount == 0)
                }

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
        .alert("Delete Program", isPresented: Binding(
            get: { deleteTarget != nil },
            set: { if !$0 { deleteTarget = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let target = deleteTarget {
                    configManager.removeProgram(id: target.id)
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

    private func fetchProgram(_ program: CloneableProgram) async {
        fetchingProgramId = program.id
        let result = await ProgramInspector.inspect(
            address: program.address,
            cluster: program.cluster
        )
        if result.isProgram && result.isUpgradeable != program.isUpgradeable {
            var updated = program
            updated.isUpgradeable = result.isUpgradeable
            configManager.updateProgram(updated)
        }
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
        fetchingProgramId = nil
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
    var onFetch: (() -> Void)? = nil
    var onCopyAddress: (() -> Void)? = nil
    var isFetching: Bool = false

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
                        .onTapGesture { onCopyAddress?() }
                        .help("Click to copy address")
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

            if isFetching {
                ProgressView()
                    .controlSize(.small)
            } else if let onFetch {
                Button(action: onFetch) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help("Fetch latest program info")
            }

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
