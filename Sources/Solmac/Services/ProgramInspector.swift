import Foundation

struct InspectionResult: Sendable {
    let isProgram: Bool
    let isUpgradeable: Bool
    let programDataAddress: String?
    let authority: String?
    let associatedAccounts: [(address: String, label: String)]
}

enum ProgramInspector {
    /// Inspect a program address on the given cluster.
    /// Detects upgradeability, fetches programdata address, and returns associated accounts.
    static func inspect(
        address: String,
        cluster: ClusterSource,
        solanaPath: String? = nil
    ) async -> InspectionResult {
        let solana = resolveSolanaPath(solanaPath)

        // Run `solana program show <address> --url <cluster>`
        guard let result = try? await ProcessRunner.run(
            executable: solana,
            arguments: ["program", "show", address, "--url", cluster.url]
        ) else {
            return InspectionResult(
                isProgram: false, isUpgradeable: false,
                programDataAddress: nil, authority: nil, associatedAccounts: []
            )
        }

        let output = result.stdout + result.stderr

        // Check if it's a valid program
        let isProgram = output.contains("Program Id") || output.contains("ProgramData Address")
        let isUpgradeable = output.contains("Upgradeable")

        // Extract ProgramData address
        let programData = extractField(from: output, field: "ProgramData Address")
        let authority = extractField(from: output, field: "Authority")

        // Collect associated accounts
        var associated: [(address: String, label: String)] = []

        // If upgradeable and has a programdata address, it'll be cloned
        // via --clone-upgradeable-program automatically. But if we're
        // pre-fetching, we need the programdata account too.
        if let programData, !programData.isEmpty {
            associated.append((address: programData, label: "\(address.prefix(8))... ProgramData"))
        }

        return InspectionResult(
            isProgram: isProgram,
            isUpgradeable: isUpgradeable,
            programDataAddress: programData,
            authority: authority,
            associatedAccounts: associated
        )
    }

    private static func extractField(from output: String, field: String) -> String? {
        for line in output.components(separatedBy: .newlines) {
            if line.contains(field) {
                let parts = line.components(separatedBy: ":")
                if parts.count >= 2 {
                    let value = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    if !value.isEmpty && value != "none" {
                        return value
                    }
                }
            }
        }
        return nil
    }

    private static func resolveSolanaPath(_ provided: String?) -> String {
        if let provided, !provided.isEmpty {
            // Derive solana from solana-test-validator path
            let dir = URL(fileURLWithPath: provided).deletingLastPathComponent().path
            let solanaPath = "\(dir)/solana"
            if FileManager.default.isExecutableFile(atPath: solanaPath) {
                return solanaPath
            }
        }
        if let found = ProcessRunner.findBinary(named: "solana") {
            return found
        }
        let defaultPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/share/solana/install/active_release/bin/solana")
            .path
        if FileManager.default.isExecutableFile(atPath: defaultPath) {
            return defaultPath
        }
        return "solana"
    }
}
