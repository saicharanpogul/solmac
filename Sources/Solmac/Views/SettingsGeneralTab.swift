import SwiftUI
import UniformTypeIdentifiers

struct SettingsGeneralTab: View {
    @Environment(ConfigManager.self) private var configManager
    @State private var showExportPanel = false
    @State private var showImportPanel = false
    @State private var importError: String?
    @State private var newProfileName = ""
    @State private var profileError: String?
    @State private var deleteProfileTarget: String?

    var body: some View {
        @Bindable var cm = configManager

        Form {
            Section("Validator") {
                TextField("Validator Path", text: $cm.config.validatorPath, prompt: Text("Auto-detect"))
                TextField("Ledger Directory", text: $cm.config.ledgerDirectory)
                Toggle("Reset ledger on start", isOn: $cm.config.resetOnStart)
                Toggle("Auto-start validator on launch", isOn: $cm.config.autoStartOnLaunch)
            }

            Section("Ports") {
                HStack {
                    Text("RPC Port")
                        .frame(width: 100, alignment: .leading)
                    TextField("8899", value: $cm.config.rpcPort, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    Text("(JSON RPC + WebSocket on next port)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Faucet Port")
                        .frame(width: 100, alignment: .leading)
                    TextField("9900", value: $cm.config.faucetPort, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                HStack {
                    Text("Gossip Port")
                        .frame(width: 100, alignment: .leading)
                    TextField("0", value: $cm.config.gossipPort, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    Text("(0 = auto)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Additional Arguments") {
                TextField(
                    "Extra CLI flags",
                    text: additionalArgsBinding,
                    prompt: Text("e.g. --rpc-port 8899 --faucet-sol 100"),
                    axis: .vertical
                )
                .lineLimit(3...6)
                Text("One argument per space-separated token. These are appended to the validator command.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Profiles") {
                if configManager.availableProfiles.isEmpty {
                    Text("No saved profiles")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    ForEach(configManager.availableProfiles, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            Button("Load") {
                                do {
                                    try configManager.loadProfile(named: name)
                                } catch {
                                    profileError = error.localizedDescription
                                }
                            }
                            .controlSize(.small)
                            Button {
                                deleteProfileTarget = name
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                            .controlSize(.small)
                        }
                    }
                }
                HStack {
                    TextField("Profile name", text: $newProfileName, prompt: Text("e.g. DeFi Dev"))
                        .textFieldStyle(.roundedBorder)
                    Button("Save Current") {
                        let name = newProfileName.trimmingCharacters(in: .whitespaces)
                        guard !name.isEmpty else { return }
                        do {
                            try configManager.saveProfile(named: name)
                            newProfileName = ""
                        } catch {
                            profileError = error.localizedDescription
                        }
                    }
                    .controlSize(.small)
                    .disabled(newProfileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("Configuration") {
                LabeledContent("Config File") {
                    Text(SolmacConstants.configFile.path)
                        .textSelection(.enabled)
                        .font(.caption)
                }
                LabeledContent("Log File") {
                    Text(SolmacConstants.logFile.path)
                        .textSelection(.enabled)
                        .font(.caption)
                }
                HStack(spacing: 12) {
                    Button("Open Config Directory") {
                        NSWorkspace.shared.open(SolmacConstants.configDir)
                    }
                    Spacer()
                    Button("Export Config...") {
                        showExportPanel = true
                    }
                    Button("Import Config...") {
                        showImportPanel = true
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .fileExporter(
            isPresented: $showExportPanel,
            document: ConfigDocument(config: configManager.config),
            contentType: .json,
            defaultFilename: "solmac-config.json"
        ) { result in
            if case .failure(let error) = result {
                importError = error.localizedDescription
            }
        }
        .fileImporter(
            isPresented: $showImportPanel,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                do {
                    try configManager.importConfig(from: url)
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
        .alert("Import Error", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("OK") { importError = nil }
        } message: {
            if let importError {
                Text(importError)
            }
        }
        .alert("Delete Profile", isPresented: Binding(
            get: { deleteProfileTarget != nil },
            set: { if !$0 { deleteProfileTarget = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let name = deleteProfileTarget {
                    try? configManager.deleteProfile(named: name)
                }
                deleteProfileTarget = nil
            }
            Button("Cancel", role: .cancel) { deleteProfileTarget = nil }
        } message: {
            if let name = deleteProfileTarget {
                Text("Delete profile \"\(name)\"?")
            }
        }
        .alert("Profile Error", isPresented: Binding(
            get: { profileError != nil },
            set: { if !$0 { profileError = nil } }
        )) {
            Button("OK") { profileError = nil }
        } message: {
            if let profileError {
                Text(profileError)
            }
        }
    }

    private var additionalArgsBinding: Binding<String> {
        @Bindable var cm = configManager
        return Binding(
            get: { cm.config.additionalArgs.joined(separator: " ") },
            set: { newValue in
                cm.config.additionalArgs = newValue
                    .split(separator: " ")
                    .map(String.init)
            }
        )
    }
}

/// FileDocument wrapper for exporting config via NSSavePanel
struct ConfigDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let config: SolmacConfig

    init(config: SolmacConfig) {
        self.config = config
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        config = try JSONDecoder().decode(SolmacConfig.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        return FileWrapper(regularFileWithContents: data)
    }
}
