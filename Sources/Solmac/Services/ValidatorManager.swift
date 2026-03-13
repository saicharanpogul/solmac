import Foundation

@Observable
@MainActor
final class ValidatorManager {
    private(set) var state: ValidatorState = .stopped

    private var process: Process?
    private let configManager: ConfigManager
    private let logManager: LogManager
    private var monitorTask: Task<Void, Never>?

    init(configManager: ConfigManager, logManager: LogManager) {
        self.configManager = configManager
        self.logManager = logManager
    }

    func start() async {
        guard state.canStart else { return }

        do {
            let validatorPath = resolveValidatorPath()

            // Pre-fetch cross-cluster items
            let solanaPath = validatorPath // same directory
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
                prefetchResult: prefetchResult
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

            // Monitor for exit
            let stoppingState = state
            _ = stoppingState // suppress warning
            monitorTask = Task { @MainActor [weak self] in
                // Wait for process exit on a background thread
                let exitCode = await withCheckedContinuation { continuation in
                    DispatchQueue.global().async {
                        proc.waitUntilExit()
                        continuation.resume(returning: proc.terminationStatus)
                    }
                }
                guard let self else { return }
                if exitCode == 0 || self.state == .stopping {
                    self.state = .stopped
                } else {
                    self.state = .error(message: "Exited with code \(exitCode)")
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
        monitorTask?.cancel()
        if let process, process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }
    }

    private func resolveValidatorPath() -> String {
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
