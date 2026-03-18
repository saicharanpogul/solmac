import Foundation
import UserNotifications

@Observable
@MainActor
final class ValidatorManager {
    private(set) var state: ValidatorState = .stopped
    let healthCheck = HealthCheckService()

    private var process: Process?
    private let configManager: ConfigManager
    private let logManager: LogManager
    private var monitorTask: Task<Void, Never>?
    private(set) var validatorVersion: String?

    init(configManager: ConfigManager, logManager: LogManager) {
        self.configManager = configManager
        self.logManager = logManager
        requestNotificationPermission()
        detectVersion()
    }

    var rpcURL: String {
        "http://127.0.0.1:\(configManager.config.rpcPort)"
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func sendCrashNotification(exitCode: Int32) {
        let content = UNMutableNotificationContent()
        content.title = "Validator Crashed"
        content.body = "solana-test-validator exited unexpectedly with code \(exitCode)"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "validator-crash", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func detectVersion() {
        Task.detached {
            let path = await self.resolveValidatorPath()
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = ["--version"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            do {
                try process.run()
                process.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) {
                    // Output like "solana-test-validator 1.18.22 (src:...)"
                    let version = output
                        .replacingOccurrences(of: "solana-test-validator ", with: "")
                        .components(separatedBy: " ").first ?? output
                    await MainActor.run {
                        self.validatorVersion = version
                    }
                }
            } catch {}
        }
    }

    func airdrop(to address: String, amount: Double = 2.0) async -> Bool {
        let solanaPath = resolveValidatorPath()
            .replacingOccurrences(of: "solana-test-validator", with: "solana")
        do {
            let result = try await ProcessRunner.run(
                executable: solanaPath,
                arguments: [
                    "airdrop", String(amount),
                    address,
                    "--url", rpcURL
                ]
            )
            if result.exitCode == 0 {
                logManager.append("[INFO] Airdropped \(amount) SOL to \(address)")
                return true
            } else {
                logManager.append("[WARN] Airdrop failed: \(result.stderr)")
                return false
            }
        } catch {
            logManager.append("[ERROR] Airdrop error: \(error.localizedDescription)")
            return false
        }
    }

    func start(forceReset: Bool = false) async {
        guard state.canStart else { return }

        do {
            let validatorPath = resolveValidatorPath()

            // Pre-fetch cross-cluster items
            let solanaPath = validatorPath
            let preFetchService = PreFetchService(solanaPath: solanaPath)

            state = .prefetching(progress: "Preparing...")

            let prefetchResult = try await preFetchService.prefetch(
                programs: configManager.config.programs,
                accounts: configManager.config.accounts,
                onProgress: { [weak self] msg in
                    Task { @MainActor in
                        self?.state = .prefetching(progress: msg)
                    }
                }
            )

            for warning in prefetchResult.warnings {
                logManager.append("[WARN] \(warning)")
            }

            // Build command
            let args = CommandBuilder.buildArguments(
                config: configManager.config,
                prefetchResult: prefetchResult,
                forceReset: forceReset
            )

            logManager.append("[INFO] Starting: \(validatorPath) \(args.joined(separator: " "))")

            // Spawn process
            state = .starting
            let (proc, stdoutPipe, stderrPipe) = try ProcessRunner.spawn(
                executable: validatorPath,
                arguments: args
            )
            self.process = proc

            // Stream output to logs
            logManager.startReading(pipe: stdoutPipe)
            logManager.startReading(pipe: stderrPipe)

            state = .running(pid: proc.processIdentifier)

            // Start health check polling
            healthCheck.startPolling(rpcPort: configManager.config.rpcPort)

            // Monitor for exit
            monitorTask = Task { @MainActor [weak self] in
                let exitCode = await withCheckedContinuation { continuation in
                    DispatchQueue.global().async {
                        proc.waitUntilExit()
                        continuation.resume(returning: proc.terminationStatus)
                    }
                }
                guard let self else { return }
                self.healthCheck.stopPolling()
                if exitCode == 0 || self.state == .stopping {
                    self.state = .stopped
                } else {
                    self.state = .error(message: "Exited with code \(exitCode)")
                    self.sendCrashNotification(exitCode: exitCode)
                }
                self.process = nil
            }

        } catch {
            state = .error(message: error.localizedDescription)
            logManager.append("[ERROR] \(error.localizedDescription)")
        }
    }

    func stop() {
        guard state.canStop, let process else { return }
        state = .stopping
        logManager.append("[INFO] Stopping validator (PID \(process.processIdentifier))...")

        process.terminate()

        Task {
            try? await Task.sleep(for: .seconds(5))
            if process.isRunning {
                logManager.append("[WARN] Validator did not stop after 5s, sending SIGKILL")
                kill(process.processIdentifier, SIGKILL)
            }
        }
    }

    func cleanup() {
        healthCheck.stopPolling()
        monitorTask?.cancel()
        if let process, process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }
    }

    func resolveValidatorPath() -> String {
        let configPath = configManager.config.validatorPath
        if !configPath.isEmpty {
            return configPath
        }

        // Try login shell which
        if let path = ProcessRunner.findBinary(named: "solana-test-validator") {
            return path
        }

        // Known default path
        let defaultPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/share/solana/install/active_release/bin/solana-test-validator")
            .path
        if FileManager.default.isExecutableFile(atPath: defaultPath) {
            return defaultPath
        }

        return "solana-test-validator"
    }
}
