import SwiftUI

struct SettingsPresetsTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var selectedBrand: Brand? = nil
    @State private var searchText = ""
    @State private var clusterOverride: [UUID: ClusterSource] = [:]

    private var filteredPresets: [ProgramPreset] {
        var presets = ProgramPresets.all
        if let brand = selectedBrand {
            presets = presets.filter { $0.brand == brand }
        }
        if !searchText.isEmpty {
            presets = presets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.brand.rawValue.localizedCaseInsensitiveContains(searchText)
                    || $0.programAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
        return presets
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search programs...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            // Brand filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    BrandFilterChip(label: "All", icon: nil, isSelected: selectedBrand == nil) {
                        selectedBrand = nil
                    }
                    ForEach(ProgramPresets.brands) { brand in
                        BrandFilterChip(label: brand.rawValue, icon: brand, isSelected: selectedBrand == brand) {
                            selectedBrand = selectedBrand == brand ? nil : brand
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }

            Divider()

            // Presets list
            List {
                ForEach(filteredPresets) { preset in
                    HStack(spacing: 10) {
                        BrandIcon(brand: preset.brand, size: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(preset.brand.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(preset.name)
                                    .fontWeight(.medium)
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
                                .font(.system(.caption2, design: .monospaced))
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
                            // Cluster picker for this preset
                            Picker("", selection: clusterBinding(for: preset.id)) {
                                ForEach(ClusterSource.allCases) { source in
                                    Text(source.displayName).tag(source)
                                }
                            }
                            .frame(width: 90)
                            .controlSize(.small)

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

            HStack {
                Text("\(filteredPresets.count) programs")
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

    private func clusterBinding(for id: UUID) -> Binding<ClusterSource> {
        Binding(
            get: { clusterOverride[id] ?? .mainnetBeta },
            set: { clusterOverride[id] = $0 }
        )
    }

    private func isAlreadyAdded(_ preset: ProgramPreset) -> Bool {
        configManager.config.programs.contains { $0.address == preset.programAddress }
    }

    private func addPreset(_ preset: ProgramPreset) {
        let cluster = clusterOverride[preset.id] ?? .mainnetBeta
        let program = CloneableProgram(
            address: preset.programAddress,
            label: "\(preset.brand.rawValue) \(preset.name)",
            cluster: cluster,
            isEnabled: true,
            isUpgradeable: preset.isUpgradeable
        )
        configManager.addProgram(program)

        for assoc in preset.associatedAccounts {
            if !configManager.config.accounts.contains(where: { $0.address == assoc.address }) {
                configManager.addAccount(CloneableAccount(
                    address: assoc.address,
                    label: assoc.label,
                    cluster: cluster,
                    isEnabled: true,
                    useMaybeClone: true
                ))
            }
        }
    }
}

struct BrandFilterChip: View {
    let label: String
    let icon: Brand?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    BrandIcon(brand: icon, size: 16)
                }
                Text(label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.05))
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

