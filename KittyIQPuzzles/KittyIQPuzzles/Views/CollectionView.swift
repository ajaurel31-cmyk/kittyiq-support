import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    private var collectibles: [Collectible] {
        [
            // World 1
            Collectible(id: "yarn_ball", name: "Yarn Ball", emoji: "🧶", description: "A classic toy for any cat", worldId: 1),
            Collectible(id: "fish_toy", name: "Fish Toy", emoji: "🐟", description: "Whiskers' favorite snack", worldId: 1),
            Collectible(id: "butterfly", name: "Butterfly", emoji: "🦋", description: "Found fluttering in the garden", worldId: 1),
            // World 2
            Collectible(id: "milk_bowl", name: "Milk Bowl", emoji: "🥛", description: "Warm milk before bedtime", worldId: 2),
            Collectible(id: "cozy_box", name: "Cozy Box", emoji: "📦", description: "If it fits, I sits", worldId: 2),
            Collectible(id: "mouse_toy", name: "Mouse Toy", emoji: "🐭", description: "Squeak squeak!", worldId: 2),
            // World 3
            Collectible(id: "bird", name: "City Bird", emoji: "🐦", description: "Spotted from the rooftop", worldId: 3),
            Collectible(id: "moonlight", name: "Moonlight", emoji: "🌕", description: "A rooftop moonlit night", worldId: 3),
            Collectible(id: "fish_bone", name: "Fish Bone", emoji: "🦴", description: "From the alley dumpster", worldId: 3),
            // World 4
            Collectible(id: "mushroom", name: "Magic Mushroom", emoji: "🍄", description: "Glowing in the dark forest", worldId: 4),
            Collectible(id: "crystal", name: "Crystal", emoji: "💎", description: "Hidden under enchanted leaves", worldId: 4),
            Collectible(id: "feather", name: "Owl Feather", emoji: "🪶", description: "A gift from a forest friend", worldId: 4),
            // World 5
            Collectible(id: "star", name: "Dream Star", emoji: "⭐", description: "Caught in a catnip dream", worldId: 5),
            Collectible(id: "rainbow", name: "Rainbow", emoji: "🌈", description: "Only visible in dreams", worldId: 5),
            Collectible(id: "golden_fish", name: "Golden Fish", emoji: "🐠", description: "The legendary golden catch", worldId: 5),
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress
                    let collected = collectibles.filter { isCollected($0) }.count
                    VStack(spacing: 8) {
                        Text("📖")
                            .font(.system(size: 50))
                        Text("\(collected)/\(collectibles.count) Collected")
                            .font(.headline)
                        ProgressView(value: Double(collected), total: Double(collectibles.count))
                            .tint(.orange)
                            .padding(.horizontal, 60)
                    }
                    .padding()

                    // Grid by world
                    ForEach(gameState.worlds) { world in
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(world.emoji) \(world.name)")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(collectibles.filter { $0.worldId == world.id }) { item in
                                    CollectibleCard(item: item, isCollected: isCollected(item))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Collection")
        }
    }

    private func isCollected(_ item: Collectible) -> Bool {
        // Items are collected by completing levels in that world
        let worldLevels = gameState.worlds.first { $0.id == item.worldId }?.levels ?? []
        let completedInWorld = worldLevels.filter { gameState.completedLevels["\(item.worldId)-\($0.id)"] != nil }.count

        // Unlock collectibles at 5, 10, 15 levels completed in the world
        let itemsForWorld = collectibles.filter { $0.worldId == item.worldId }
        guard let itemIndex = itemsForWorld.firstIndex(where: { $0.id == item.id }) else { return false }

        let thresholds = [5, 10, 15]
        if itemIndex < thresholds.count {
            return completedInWorld >= thresholds[itemIndex]
        }
        return false
    }

    private var collectibles_all: [Collectible] { collectibles }
}

struct CollectibleCard: View {
    let item: Collectible
    let isCollected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(isCollected ? item.emoji : "❓")
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCollected ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                )

            Text(isCollected ? item.name : "???")
                .font(.caption)
                .foregroundColor(isCollected ? .primary : .secondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    CollectionView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
