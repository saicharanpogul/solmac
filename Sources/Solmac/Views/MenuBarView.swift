import SwiftUI

struct MenuBarView: View {
    @Environment(ValidatorManager.self) private var validator
    @Environment(ConfigManager.self) private var config
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Section {
            Label(validator.state.statusText, systemImage: validator.state.iconName)
                .disabled(true)
        }

        Section {
            if validator.state.canStart {
                Button("Start Validator") {
                    Task { await validator.start() }
                }
                .keyboardShortcut("s", modifiers: [.command])
            } else if validator.state.canStop {
                Button("Stop Validator") {
                    validator.stop()
                }
                .keyboardShortcut("s", modifiers: [.command])
            } else {
                Button(validator.state.statusText) {}
                    .disabled(true)
            }
        }

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
