import SwiftUI

struct SettingsGeneralTab: View {
    @Environment(ConfigManager.self) private var configManager

    var body: some View {
        @Bindable var cm = configManager

        Form {
            Section("Validator") {
                TextField("Validator Path", text: $cm.config.validatorPath, prompt: Text("Auto-detect"))
                TextField("Ledger Directory", text: $cm.config.ledgerDirectory)
                Toggle("Reset ledger on start", isOn: $cm.config.resetOnStart)
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

            Section("Paths") {
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
                Button("Open Config Directory") {
                    NSWorkspace.shared.open(SolmacConstants.configDir)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
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
