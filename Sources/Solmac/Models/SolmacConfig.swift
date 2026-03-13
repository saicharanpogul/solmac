import Foundation

struct SolmacConfig: Codable {
    var programs: [CloneableProgram]
    var accounts: [CloneableAccount]
    var ledgerDirectory: String
    var resetOnStart: Bool
    var validatorPath: String
    var rpcPort: Int
    var faucetPort: Int
    var gossipPort: Int
    var additionalArgs: [String]

    static let `default` = SolmacConfig(
        programs: [],
        accounts: [],
        ledgerDirectory: FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/solmac/test-ledger").path,
        resetOnStart: true,
        validatorPath: "",
        rpcPort: 8899,
        faucetPort: 9900,
        gossipPort: 0,
        additionalArgs: []
    )
}
