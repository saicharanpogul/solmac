import Foundation

struct CloneableProgram: Codable, Identifiable, Hashable {
    let id: UUID
    var address: String
    var label: String
    var cluster: ClusterSource
    var isEnabled: Bool
    var isUpgradeable: Bool

    init(
        id: UUID = UUID(),
        address: String,
        label: String = "",
        cluster: ClusterSource = .mainnetBeta,
        isEnabled: Bool = true,
        isUpgradeable: Bool = true
    ) {
        self.id = id
        self.address = address
        self.label = label.isEmpty ? address : label
        self.cluster = cluster
        self.isEnabled = isEnabled
        self.isUpgradeable = isUpgradeable
    }
}

struct CloneableAccount: Codable, Identifiable, Hashable {
    let id: UUID
    var address: String
    var label: String
    var cluster: ClusterSource
    var isEnabled: Bool
    var useMaybeClone: Bool

    init(
        id: UUID = UUID(),
        address: String,
        label: String = "",
        cluster: ClusterSource = .mainnetBeta,
        isEnabled: Bool = true,
        useMaybeClone: Bool = false
    ) {
        self.id = id
        self.address = address
        self.label = label.isEmpty ? address : label
        self.cluster = cluster
        self.isEnabled = isEnabled
        self.useMaybeClone = useMaybeClone
    }
}
