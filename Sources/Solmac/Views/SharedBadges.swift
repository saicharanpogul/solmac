import SwiftUI

struct ClusterBadge: View {
    let cluster: ClusterSource

    var body: some View {
        Text(cluster.displayName)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch cluster {
        case .mainnetBeta: .green
        case .devnet: .purple
        case .testnet: .orange
        }
    }
}
