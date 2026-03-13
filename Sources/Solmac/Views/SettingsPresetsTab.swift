import SwiftUI

struct SettingsPresetsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var selectedCategory: PresetCategory? = nil
    @State private var searchText = ""

    private var filteredPresets: [ProgramPreset] {
        var presets = ProgramPresets.all
        if let cat = selectedCategory {
            presets = presets.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            presets = presets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.programAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
        return presets
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            HStack(spacing: 8) {
                TextField("Search programs...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as PresetCategory?)
                    ForEach(PresetCategory.allCases) { cat in
                        Text(cat.rawValue).tag(cat as PresetCategory?)
                    }
                }
                .frame(width: 180)
            }
            .padding(8)

            Divider()

            // Presets list
            List {
                ForEach(filteredPresets) { preset in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(preset.name)
                                    .fontWeight(.medium)
                                CategoryBadge(category: preset.category)
                                if preset.isUpgradeable {
                                    Text("Upgradeable")
                                        .font(.caption2)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(.blue.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                            Text(preset.programAddress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                            if !preset.associatedAccounts.isEmpty {
                                Text("+\(preset.associatedAccounts.count) associated account(s)")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }

                        Spacer()

                        if isAlreadyAdded(preset) {
                            Label("Added", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Button("Add") {
                                addPreset(preset)
                            }
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Divider()

            // Summary
            HStack {
                Text("\(filteredPresets.count) programs available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Add All Visible") {
                    for preset in filteredPresets where !isAlreadyAdded(preset) {
                        addPreset(preset)
                    }
                }
                .controlSize(.small)
                .disabled(filteredPresets.allSatisfy { isAlreadyAdded($0) })
            }
            .padding(8)
        }
    }

    private func isAlreadyAdded(_ preset: ProgramPreset) -> Bool {
        configManager.config.programs.contains { $0.address == preset.programAddress }
    }

    private func addPreset(_ preset: ProgramPreset) {
        // Add the program
        let program = CloneableProgram(
            address: preset.programAddress,
            label: preset.name,
            cluster: .mainnetBeta,
            isEnabled: true,
            isUpgradeable: preset.isUpgradeable
        )
        configManager.addProgram(program)

        // Add associated accounts
        for assoc in preset.associatedAccounts {
            // Avoid duplicates
            if !configManager.config.accounts.contains(where: { $0.address == assoc.address }) {
                let account = CloneableAccount(
                    address: assoc.address,
                    label: assoc.label,
                    cluster: .mainnetBeta,
                    isEnabled: true,
                    useMaybeClone: true
                )
                configManager.addAccount(account)
            }
        }
    }
}

struct CategoryBadge: View {
    let category: PresetCategory

    var body: some View {
        Text(category.rawValue)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch category {
        case .tokenNFT: .purple
        case .defi: .green
        case .oracle: .orange
        case .infrastructure: .blue
        }
    }
}
