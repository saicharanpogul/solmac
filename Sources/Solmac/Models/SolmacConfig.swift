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
    var autoStartOnLaunch: Bool

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
        additionalArgs: [],
        autoStartOnLaunch: false
    )

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        programs = try container.decode([CloneableProgram].self, forKey: .programs)
        accounts = try container.decode([CloneableAccount].self, forKey: .accounts)
        ledgerDirectory = try container.decode(String.self, forKey: .ledgerDirectory)
        resetOnStart = try container.decode(Bool.self, forKey: .resetOnStart)
        validatorPath = try container.decode(String.self, forKey: .validatorPath)
        rpcPort = try container.decode(Int.self, forKey: .rpcPort)
        faucetPort = try container.decode(Int.self, forKey: .faucetPort)
        gossipPort = try container.decode(Int.self, forKey: .gossipPort)
        additionalArgs = try container.decode([String].self, forKey: .additionalArgs)
        autoStartOnLaunch = try container.decodeIfPresent(Bool.self, forKey: .autoStartOnLaunch) ?? false
    }

    init(
        programs: [CloneableProgram],
        accounts: [CloneableAccount],
        ledgerDirectory: String,
        resetOnStart: Bool,
        validatorPath: String,
        rpcPort: Int,
        faucetPort: Int,
        gossipPort: Int,
        additionalArgs: [String],
        autoStartOnLaunch: Bool = false
    ) {
        self.programs = programs
        self.accounts = accounts
        self.ledgerDirectory = ledgerDirectory
        self.resetOnStart = resetOnStart
        self.validatorPath = validatorPath
        self.rpcPort = rpcPort
        self.faucetPort = faucetPort
        self.gossipPort = gossipPort
        self.additionalArgs = additionalArgs
        self.autoStartOnLaunch = autoStartOnLaunch
    }
}
