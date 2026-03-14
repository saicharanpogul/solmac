import SwiftUI

@main
struct SolmacApp: App {
    @State private var configManager = ConfigManager()
    @State private var logManager = LogManager()
    @State private var validatorManager: ValidatorManager?

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(configManager)
                .environment(logManager)
                .environment(validatorManager!)
                .task {
                    guard let vm = validatorManager,
                          configManager.config.autoStartOnLaunch,
                          vm.state.canStart else { return }
                    await vm.start()
                }
        } label: {
            let isRunning = validatorManager?.state.isRunning ?? false
            Image(nsImage: isRunning ? SolanaIcon.filled : SolanaIcon.outline)
        }
        .menuBarExtraStyle(.menu)

        Window("Solmac Settings", id: "settings") {
            SettingsWindow()
                .environment(configManager)
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 700, height: 500)

        Window("Validator Logs", id: "log-viewer") {
            LogViewerWindow()
                .environment(logManager)
                .frame(minWidth: 500, minHeight: 300)
        }
        .defaultSize(width: 800, height: 500)
    }

    init() {
        let cm = ConfigManager()
        let lm = LogManager()
        _configManager = State(initialValue: cm)
        _logManager = State(initialValue: lm)
        _validatorManager = State(initialValue: ValidatorManager(configManager: cm, logManager: lm))
    }
}
