import Foundation

struct PreFetchResult: Sendable {
    let primaryCluster: ClusterSource
    let nativeCloneAccounts: [CloneableAccount]
    let nativeClonePrograms: [CloneableProgram]
    let prefetchedAccounts: [(address: String, filePath: String)]
    let prefetchedPrograms: [(address: String, filePath: String, isUpgradeable: Bool)]
    let warnings: [String]

    static let empty = PreFetchResult(
        primaryCluster: .mainnetBeta,
        nativeCloneAccounts: [],
        nativeClonePrograms: [],
        prefetchedAccounts: [],
        prefetchedPrograms: [],
        warnings: []
    )
}

enum CommandBuilder {
    static func buildArguments(
        config: SolmacConfig,
        prefetchResult: PreFetchResult,
        forceReset: Bool = false
    ) -> [String] {
        var args: [String] = []

        args += ["--ledger", config.ledgerDirectory]

        if config.resetOnStart || forceReset {
            args.append("--reset")
        }

        args += ["--url", prefetchResult.primaryCluster.url]

        // Ports
        args += ["--rpc-port", String(config.rpcPort)]
        args += ["--faucet-port", String(config.faucetPort)]
        if config.gossipPort > 0 {
            args += ["--gossip-port", String(config.gossipPort)]
        }

        // Native clone accounts (on primary cluster)
        for account in prefetchResult.nativeCloneAccounts {
            if account.useMaybeClone {
                args += ["--maybe-clone", account.address]
            } else {
                args += ["--clone", account.address]
            }
        }

        // Native clone programs (on primary cluster)
        for program in prefetchResult.nativeClonePrograms {
            if program.isUpgradeable {
                args += ["--clone-upgradeable-program", program.address]
            } else {
                args += ["--clone", program.address]
            }
        }

        // Pre-fetched accounts (from non-primary clusters)
        for item in prefetchResult.prefetchedAccounts {
            args += ["--account", item.address, item.filePath]
        }

        // Pre-fetched programs (from non-primary clusters)
        for item in prefetchResult.prefetchedPrograms {
            if item.isUpgradeable {
                args += ["--upgradeable-program", item.address, item.filePath, "none"]
            } else {
                args += ["--bpf-program", item.address, item.filePath]
            }
        }

        args += config.additionalArgs

        return args
    }
}
