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
                VStack(spacing: 24) {
                    // Progress header
                    let collected = collectibles.filter { isCollected($0) }.count
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 64, height: 64)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.heroGradient)
                        }

                        Text("\(collected) of \(collectibles.count)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(AppTheme.textPrimary)

                        // Custom progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppTheme.accent.opacity(0.12))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(AppTheme.heroGradient)
                                    .frame(width: geo.size.width * CGFloat(collected) / CGFloat(collectibles.count), height: 6)
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal, 60)
                    }
                    .padding(.vertical, 8)

                    // Grid by world
                    ForEach(gameState.worlds) { world in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: AppTheme.worldIcon(for: world.theme))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(AppTheme.worldColor(for: world.theme))
                                Text(world.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
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
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationTitle("Collection")
        }
    }

    private func isCollected(_ item: Collectible) -> Bool {
        let worldLevels = gameState.worlds.first { $0.id == item.worldId }?.levels ?? []
        let completedInWorld = worldLevels.filter { gameState.completedLevels["\(item.worldId)-\($0.id)"] != nil }.count

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
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isCollected ? AppTheme.accent.opacity(0.1) : Color.gray.opacity(0.06))
                    .frame(width: 60, height: 60)

                if isCollected {
                    Text(item.emoji)
                        .font(.system(size: 28))
                } else {
                    Image(systemName: "questionmark")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.3))
                }
            }

            Text(isCollected ? item.name : "???")
                .font(.caption.weight(.medium))
                .foregroundColor(isCollected ? AppTheme.textPrimary : AppTheme.textSecondary.opacity(0.5))
                .lineLimit(1)
        }
    }
}

#Preview {
    CollectionView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
