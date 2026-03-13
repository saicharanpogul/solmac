import Foundation

enum ClusterSource: String, Codable, CaseIterable, Identifiable {
    case mainnetBeta = "mainnet-beta"
    case devnet = "devnet"
    case testnet = "testnet"

    var id: String { rawValue }

    var url: String {
        switch self {
        case .mainnetBeta: "https://api.mainnet-beta.solana.com"
        case .devnet: "https://api.devnet.solana.com"
        case .testnet: "https://api.testnet.solana.com"
        }
    }

    var displayName: String {
        switch self {
        case .mainnetBeta: "Mainnet"
        case .devnet: "Devnet"
        case .testnet: "Testnet"
        }
    }

    /// Priority for tie-breaking when picking primary cluster
    var priority: Int {
        switch self {
        case .mainnetBeta: 0
        case .devnet: 1
        case .testnet: 2
        }
    }
}
