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
    static let all: [ProgramPreset] = tokenNFT + defi + oracle + infrastructure

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
