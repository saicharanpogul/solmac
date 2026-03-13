import Foundation

actor PreFetchService {
    private let solanaPath: String
    private let maxConcurrency = 4

    init(solanaPath: String) {
        self.solanaPath = solanaPath
    }

    func prefetch(
        programs: [CloneableProgram],
        accounts: [CloneableAccount],
        onProgress: @escaping @Sendable (String) -> Void
    ) async throws -> PreFetchResult {
        let enabledPrograms = programs.filter(\.isEnabled)
        let enabledAccounts = accounts.filter(\.isEnabled)

        // Nothing to do
        if enabledPrograms.isEmpty && enabledAccounts.isEmpty {
            return .empty
        }

        // Determine primary cluster
        let primaryCluster = determinePrimaryCluster(
            programs: enabledPrograms,
            accounts: enabledAccounts
        )

        // Split into native (primary cluster) and prefetch (other clusters)
        let nativePrograms = enabledPrograms.filter { $0.cluster == primaryCluster }
        let nativeAccounts = enabledAccounts.filter { $0.cluster == primaryCluster }
        let foreignPrograms = enabledPrograms.filter { $0.cluster != primaryCluster }
        let foreignAccounts = enabledAccounts.filter { $0.cluster != primaryCluster }

        var prefetchedAccounts: [(address: String, filePath: String)] = []
        var prefetchedPrograms: [(address: String, filePath: String, isUpgradeable: Bool)] = []
        var warnings: [String] = []

        if !foreignAccounts.isEmpty || !foreignPrograms.isEmpty {
            onProgress("Fetching cross-cluster items...")

            // Fetch foreign accounts
            for account in foreignAccounts {
                onProgress("Fetching account \(account.label)...")
                do {
                    let path = try await fetchAccount(
                        address: account.address,
                        cluster: account.cluster
                    )
                    prefetchedAccounts.append((address: account.address, filePath: path))
                } catch {
                    let msg = "Failed to fetch account \(account.label) from \(account.cluster.displayName): \(error.localizedDescription)"
                    warnings.append(msg)
                }
            }

            // Fetch foreign programs
            for program in foreignPrograms {
                onProgress("Fetching program \(program.label)...")
                do {
                    let path = try await fetchProgram(
                        address: program.address,
                        cluster: program.cluster
                    )
                    prefetchedPrograms.append((
                        address: program.address,
                        filePath: path,
                        isUpgradeable: program.isUpgradeable
                    ))
                } catch {
                    let msg = "Failed to fetch program \(program.label) from \(program.cluster.displayName): \(error.localizedDescription)"
                    warnings.append(msg)
                }
            }
        }

        return PreFetchResult(
            primaryCluster: primaryCluster,
            nativeCloneAccounts: nativeAccounts,
            nativeClonePrograms: nativePrograms,
            prefetchedAccounts: prefetchedAccounts,
            prefetchedPrograms: prefetchedPrograms,
            warnings: warnings
        )
    }

    private func determinePrimaryCluster(
        programs: [CloneableProgram],
        accounts: [CloneableAccount]
    ) -> ClusterSource {
        var counts: [ClusterSource: Int] = [:]
        for p in programs { counts[p.cluster, default: 0] += 1 }
        for a in accounts { counts[a.cluster, default: 0] += 1 }

        guard !counts.isEmpty else { return .mainnetBeta }

        return counts
            .sorted { a, b in
                if a.value != b.value { return a.value > b.value }
                return a.key.priority < b.key.priority
            }
            .first!.key
    }

    private func fetchAccount(address: String, cluster: ClusterSource) async throws -> String {
        let outputPath = SolmacConstants.accountsCacheDir
            .appendingPathComponent("\(address).json").path

        let result = try await ProcessRunner.run(
            executable: solanaPath.replacingOccurrences(of: "solana-test-validator", with: "solana"),
            arguments: [
                "account", address,
                "--url", cluster.url,
                "--output", "json-compact",
                "--output-file", outputPath
            ]
        )

        if result.exitCode != 0 {
            throw PreFetchError.commandFailed(result.stderr)
        }

        return outputPath
    }

    private func fetchProgram(address: String, cluster: ClusterSource) async throws -> String {
        let outputPath = SolmacConstants.programsCacheDir
            .appendingPathComponent("\(address).so").path

        let result = try await ProcessRunner.run(
            executable: solanaPath.replacingOccurrences(of: "solana-test-validator", with: "solana"),
            arguments: [
                "program", "dump", address, outputPath,
                "--url", cluster.url
            ]
        )

        if result.exitCode != 0 {
            throw PreFetchError.commandFailed(result.stderr)
        }

        return outputPath
    }
}

enum PreFetchError: LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let msg): msg
        }
    }
}
