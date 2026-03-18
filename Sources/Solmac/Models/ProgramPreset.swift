import SwiftUI

enum Brand: String, CaseIterable, Identifiable {
    case metaplex = "Metaplex"
    case spl = "SPL"
    case jupiter = "Jupiter"
    case raydium = "Raydium"
    case orca = "Orca"
    case meteora = "Meteora"
    case marinade = "Marinade"
    case phoenix = "Phoenix"
    case drift = "Drift"
    case pyth = "Pyth"
    case switchboard = "Switchboard"
    case squads = "Squads"

    var id: String { rawValue }

    var iconResourceName: String {
        switch self {
        case .metaplex: "MPLX"
        case .spl: "SPL"
        case .jupiter: "JUP"
        case .raydium: "RAY"
        case .orca: "ORCA"
        case .meteora: "METEORA"
        case .marinade: "MNDE"
        case .phoenix: "PHOENIX"
        case .drift: "DRIFT"
        case .pyth: "PYTH"
        case .switchboard: "SWITCHBOARD"
        case .squads: "SQUADS"
        }
    }

    var initial: String {
        switch self {
        case .metaplex: "Mx"
        case .spl: "SPL"
        case .jupiter: "J"
        case .raydium: "R"
        case .orca: "O"
        case .meteora: "Me"
        case .marinade: "Mn"
        case .phoenix: "Ph"
        case .drift: "Dr"
        case .pyth: "Py"
        case .switchboard: "Sw"
        case .squads: "Sq"
        }
    }

    var color: Color {
        switch self {
        case .metaplex: Color(red: 0.96, green: 0.52, blue: 0.15)  // orange
        case .spl: Color(red: 0.60, green: 0.84, blue: 0.92)       // light blue
        case .jupiter: Color(red: 0.78, green: 0.95, blue: 0.42)   // lime green
        case .raydium: Color(red: 0.38, green: 0.45, blue: 0.98)   // blue-purple
        case .orca: Color(red: 1.0, green: 0.82, blue: 0.0)        // gold
        case .meteora: Color(red: 0.93, green: 0.29, blue: 0.60)   // pink
        case .marinade: Color(red: 0.31, green: 0.82, blue: 0.68)  // teal
        case .phoenix: Color(red: 0.91, green: 0.30, blue: 0.24)   // red
        case .drift: Color(red: 0.56, green: 0.38, blue: 0.93)     // purple
        case .pyth: Color(red: 0.42, green: 0.35, blue: 0.80)      // deep purple
        case .switchboard: Color(red: 0.10, green: 0.80, blue: 0.45) // green
        case .squads: Color(red: 0.14, green: 0.33, blue: 0.93)      // blue
        }
    }
}

struct BrandIcon: View {
    let brand: Brand
    var size: CGFloat = 24

    var body: some View {
        if let image = Self.loadIcon(named: brand.iconResourceName) {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        } else {
            // Fallback to colored initial
            Text(brand.initial)
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(brand.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        }
    }

    private static var imageCache: [String: NSImage] = [:]

    private static func loadIcon(named name: String) -> NSImage? {
        if let cached = imageCache[name] { return cached }
        // Try PNG first, then SVG
        for ext in ["png", "svg"] {
            if let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "BrandIcons"),
               let image = NSImage(contentsOf: url) {
                imageCache[name] = image
                return image
            }
        }
        return nil
    }
}

struct ProgramPreset: Identifiable {
    let id = UUID()
    let name: String
    let programAddress: String
    let isUpgradeable: Bool
    let brand: Brand
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

    static let brands: [Brand] = {
        var seen = Set<String>()
        var result: [Brand] = []
        for preset in all {
            if seen.insert(preset.brand.rawValue).inserted {
                result.append(preset.brand)
            }
        }
        return result
    }()

    // MARK: - Token & NFT

    static let tokenNFT: [ProgramPreset] = [
        ProgramPreset(
            name: "Token Metadata",
            programAddress: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
            isUpgradeable: true,
            brand: .metaplex,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Bubblegum (cNFTs)",
            programAddress: "BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPU",
            isUpgradeable: true,
            brand: .metaplex,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Candy Machine v3",
            programAddress: "CndyV3LdqHUfDLmE5naZjVN8rBZz4tqhdefbAnjHG3JR",
            isUpgradeable: true,
            brand: .metaplex,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Core",
            programAddress: "CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d",
            isUpgradeable: true,
            brand: .metaplex,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Account Compression",
            programAddress: "cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK",
            isUpgradeable: false,
            brand: .spl,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Noop",
            programAddress: "noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV",
            isUpgradeable: false,
            brand: .spl,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Token 2022",
            programAddress: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb",
            isUpgradeable: false,
            brand: .spl,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Token Program",
            programAddress: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            isUpgradeable: false,
            brand: .spl,
            category: .tokenNFT,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Associated Token Account",
            programAddress: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
            isUpgradeable: false,
            brand: .spl,
            category: .tokenNFT,
            associatedAccounts: []
        ),
    ]

    // MARK: - DeFi

    static let defi: [ProgramPreset] = [
        ProgramPreset(
            name: "Aggregator v6",
            programAddress: "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4",
            isUpgradeable: true,
            brand: .jupiter,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "AMM",
            programAddress: "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8",
            isUpgradeable: false,
            brand: .raydium,
            category: .defi,
            associatedAccounts: [
                .init(address: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1", label: "Raydium AMM Authority"),
            ]
        ),
        ProgramPreset(
            name: "CLMM",
            programAddress: "CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK",
            isUpgradeable: true,
            brand: .raydium,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "CP-Swap",
            programAddress: "CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C",
            isUpgradeable: true,
            brand: .raydium,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Whirlpool",
            programAddress: "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc",
            isUpgradeable: true,
            brand: .orca,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Staking",
            programAddress: "MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD",
            isUpgradeable: true,
            brand: .marinade,
            category: .defi,
            associatedAccounts: [
                .init(address: "8szGkuLTAux9XMgZ2vtY39jVSowEcpBfFfD8hXSEqdGC", label: "Marinade State"),
            ]
        ),
        ProgramPreset(
            name: "DEX",
            programAddress: "PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY",
            isUpgradeable: true,
            brand: .phoenix,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Protocol v2",
            programAddress: "dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH",
            isUpgradeable: true,
            brand: .drift,
            category: .defi,
            associatedAccounts: []
        ),
    ]

    // MARK: - Meteora

    static let meteora: [ProgramPreset] = [
        ProgramPreset(
            name: "DLMM",
            programAddress: "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "DAMM v2",
            programAddress: "cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "DAMM v1",
            programAddress: "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Dynamic Bonding Curve",
            programAddress: "dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Dynamic Vault",
            programAddress: "24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Alpha Vault",
            programAddress: "vaU6kP7iNEGkbmPkLmZfGwiGxd4Mob24QQCie5R9kd2",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Stake2Earn (M3M3)",
            programAddress: "FEESngU3neckdwib9X3KWqdL7Mjmqk9XNp3uh5JbP4KP",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Dynamic Fee Sharing",
            programAddress: "dfsdo2UqvwfN8DuUVrMRNfQe11VaiNoKcMqLHVvDPzh",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Zap",
            programAddress: "zapvX9M3uf5pvy4wRPAbQgdQsM1xmuiFnkfHKPvwMiz",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Presale Vault",
            programAddress: "presSVxnf9UU8jMxhgSMqaRwNiT36qeBdNeTRKjTdbj",
            isUpgradeable: true,
            brand: .meteora,
            category: .defi,
            associatedAccounts: []
        ),
    ]

    // MARK: - Oracle

    static let oracle: [ProgramPreset] = [
        ProgramPreset(
            name: "Oracle",
            programAddress: "FsJ3A3u2vn5cTVofAjvy6y5kwABJAqYWpe4975bi2epH",
            isUpgradeable: true,
            brand: .pyth,
            category: .oracle,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Oracle v2",
            programAddress: "SW1TCH7qEPTdLsDHRgPuMQjbQxKdH2aBStViMFnt64f",
            isUpgradeable: true,
            brand: .switchboard,
            category: .oracle,
            associatedAccounts: []
        ),
    ]

    // MARK: - Infrastructure

    static let infrastructure: [ProgramPreset] = [
        ProgramPreset(
            name: "Memo",
            programAddress: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr",
            isUpgradeable: false,
            brand: .spl,
            category: .infrastructure,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Name Service",
            programAddress: "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX",
            isUpgradeable: true,
            brand: .spl,
            category: .infrastructure,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Multisig v4",
            programAddress: "SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf",
            isUpgradeable: true,
            brand: .squads,
            category: .infrastructure,
            associatedAccounts: []
        ),
        ProgramPreset(
            name: "Multisig v3",
            programAddress: "SMPLecH534NA9acpos4G6x7uf3LWbCAwZQE9e8ZekMu",
            isUpgradeable: true,
            brand: .squads,
            category: .infrastructure,
            associatedAccounts: []
        ),
    ]
}
