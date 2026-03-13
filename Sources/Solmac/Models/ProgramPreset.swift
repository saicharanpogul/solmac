import Foundation

struct ProgramPreset: Identifiable {
    let id = UUID()
    let name: String
    let programAddress: String
    let isUpgradeable: Bool
    let category: PresetCategory
    let associatedAccounts: [AssociatedAccount]

    struct AssociatedAccount {
        let address: String
        let label: String
    }
}

enum PresetCategory: String, CaseIterable, Identifiable {
    case tokenNFT = "Token & NFT"
    case defi = "DeFi"
    case oracle = "Oracle"
    case infrastructure = "Infrastructure"

    var id: String { rawValue }
}

enum ProgramPresets {
    static let all: [ProgramPreset] = tokenNFT + defi + meteora + oracle + infrastructure

    // MARK: - Token & NFT

    static let tokenNFT: [ProgramPreset] = [
        ProgramPreset(
            name: "Metaplex Token Metadata",
            programAddress: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
            isUpgradeable: true,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Metaplex Bubblegum (cNFTs)",
            programAddress: "BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPU",
            isUpgradeable: true,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Metaplex Candy Machine v3",
            programAddress: "CndyV3LdqHUfDLmE5naZjVN8rBZz4tqhdefbAnjHG3JR",
            isUpgradeable: true,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Metaplex Core",
            programAddress: "CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d",
            isUpgradeable: true,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "SPL Account Compression",
            programAddress: "cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK",
            isUpgradeable: false,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "SPL Noop",
            programAddress: "noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV",
            isUpgradeable: false,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Token 2022",
            programAddress: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb",
            isUpgradeable: false,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "SPL Token",
            programAddress: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            isUpgradeable: false,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Associated Token Account",
            programAddress: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
            isUpgradeable: false,
            category: .tokenNFT,
            associatedAccounts: []
        ),
    ]

    // MARK: - DeFi

    static let defi: [ProgramPreset] = [
        ProgramPreset(
            name: "Jupiter v6",
            programAddress: "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Raydium AMM",
            programAddress: "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8",
            isUpgradeable: false,
            category: .defi,
            associatedAccounts: [
                .init(address: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1", label: "Raydium AMM Authority"),
            ]
        ),
        ProgramPreset(
            name: "Raydium CLMM",
            programAddress: "CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Raydium CP-Swap",
            programAddress: "CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Orca Whirlpool",
            programAddress: "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Marinade Finance",
            programAddress: "MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: [
                .init(address: "8szGkuLTAux9XMgZ2vtY39jVSowEcpBfFfD8hXSEqdGC", label: "Marinade State"),
            ]
        ),
        ProgramPreset(
            name: "Phoenix DEX",
            programAddress: "PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Drift Protocol",
            programAddress: "dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
    ]

    // MARK: - Meteora

    static let meteora: [ProgramPreset] = [
        ProgramPreset(
            name: "Meteora DLMM",
            programAddress: "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora DAMM v2",
            programAddress: "cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora DAMM v1",
            programAddress: "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Dynamic Bonding Curve",
            programAddress: "dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Dynamic Vault",
            programAddress: "24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Alpha Vault",
            programAddress: "vaU6kP7iNEGkbmPkLmZfGwiGxd4Mob24QQCie5R9kd2",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Stake2Earn (M3M3)",
            programAddress: "FEESngU3neckdwib9X3KWqdL7Mjmqk9XNp3uh5JbP4KP",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Dynamic Fee Sharing",
            programAddress: "dfsdo2UqvwfN8DuUVrMRNfQe11VaiNoKcMqLHVvDPzh",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Zap",
            programAddress: "zapvX9M3uf5pvy4wRPAbQgdQsM1xmuiFnkfHKPvwMiz",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Meteora Presale Vault",
            programAddress: "presSVxnf9UU8jMxhgSMqaRwNiT36qeBdNeTRKjTdbj",
            isUpgradeable: true,
            category: .defi,
            associatedAccounts: []
        ),
    ]

    // MARK: - Oracle

    static let oracle: [ProgramPreset] = [
        ProgramPreset(
            name: "Pyth Oracle",
            programAddress: "FsJ3A3u2vn5cTVofAjvy6y5kwABJAqYWpe4975bi2epH",
            isUpgradeable: true,
            category: .oracle,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Switchboard v2",
            programAddress: "SW1TCH7qEPTdLsDHRgPuMQjbQxKdH2aBStViMFnt64f",
            isUpgradeable: true,
            category: .oracle,
            associatedAccounts: []
        ),
    ]

    // MARK: - Infrastructure

    static let infrastructure: [ProgramPreset] = [
        ProgramPreset(
            name: "SPL Memo",
            programAddress: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr",
            isUpgradeable: false,
            category: .infrastructure,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "SPL Name Service",
            programAddress: "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX",
            isUpgradeable: true,
            category: .infrastructure,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Clockwork Thread v2",
            programAddress: "CLoCKyJ6DXBJqqu2VWx9RLbgnwwR6BMHHuyasVmfMzBh",
            isUpgradeable: true,
            category: .infrastructure,
            associatedAccounts: []
        ),
    ]
}
