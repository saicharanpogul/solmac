import SwiftUI

struct MenuBarView: View {
    @Environment(ValidatorManager.self) private var validator
    @Environment(ConfigManager.self) private var config
    @Environment(\.openWindow) private var openWindow
    @State private var airdropAddress = ""
    @State private var isAirdropping = false

    var body: some View {
        // Status section
        Section {
            HStack {
                Image(systemName: validator.state.iconName)
                    .foregroundStyle(validator.state.iconColor)
                Text(validator.state.statusText)
            }
            .disabled(true)

            if validator.state.isRunning {
                let h = validator.healthCheck.health
                if h.slotHeight > 0 {
                    Text("Slot: \(h.slotHeight)  |  \(String(format: "%.1f", h.tps)) slots/s")
                        .disabled(true)
                }
                Text("Uptime: \(validator.healthCheck.uptimeFormatted)")
                    .disabled(true)
            }

            if let version = validator.validatorVersion {
                Text("Version: \(version)")
                    .disabled(true)
            }
        }

        // Start / Stop
        Section {
            if validator.state.canStart {
                Button("Start Validator") {
                    Task { await validator.start() }
                }
                .keyboardShortcut("r", modifiers: [.command])
                Button("Start with Reset") {
                    Task { await validator.start(forceReset: true) }
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            } else if validator.state.canStop {
                Button("Stop Validator") {
                    validator.stop()
                }
                .keyboardShortcut(".", modifiers: [.command])
            } else {
                Button(validator.state.statusText) {}
                    .disabled(true)
            }
        }

        // Quick actions when running
        if validator.state.isRunning {
            Section {
                Button("Copy RPC URL") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(validator.rpcURL, forType: .string)
                }

                Menu("Airdrop SOL") {
                    Button("2 SOL to clipboard address") {
                        Task { await airdropFromClipboard() }
                    }
                    Divider()
                    Text("Paste address & press Return")
                        .disabled(true)
                }
            }
        }

        // Programs
        Section("Programs") {
            if config.config.programs.isEmpty {
                Text("No programs configured")
            } else {
                ForEach(config.config.programs) { program in
                    Toggle(
                        "\(program.label) (\(program.cluster.displayName))",
                        isOn: programBinding(for: program.id)
                    )
                }
            }
        }

        // Accounts
        Section("Accounts") {
            if config.config.accounts.isEmpty {
                Text("No accounts configured")
            } else {
                ForEach(config.config.accounts) { account in
                    Toggle(
                        "\(account.label) (\(account.cluster.displayName))",
                        isOn: accountBinding(for: account.id)
                    )
                }
            }
        }

        Divider()

        Button("Settings...") {
            openWindow(id: "settings")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut(",", modifiers: [.command])

        Button("View Logs...") {
            openWindow(id: "log-viewer")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut("l", modifiers: [.command])

        Divider()

        Button("Quit Solmac") {
            validator.cleanup()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }

    private func airdropFromClipboard() async {
        guard let address = NSPasteboard.general.string(forType: .string),
              !address.isEmpty,
              address.count >= 32 && address.count <= 44 else { return }
        _ = await validator.airdrop(to: address)
    }

    private func programBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { config.config.programs.first(where: { $0.id == id })?.isEnabled ?? false },
            set: { newValue in
                if var program = config.config.programs.first(where: { $0.id == id }) {
                    program.isEnabled = newValue
                    config.updateProgram(program)
                }
            }
        )
    }

    private func accountBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { config.config.accounts.first(where: { $0.id == id })?.isEnabled ?? false },
            set: { newValue in
                if var account = config.config.accounts.first(where: { $0.id == id }) {
                    account.isEnabled = newValue
                    config.updateAccount(account)
                }
            }
        )
    }
}
