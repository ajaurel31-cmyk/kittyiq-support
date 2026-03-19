import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header with cat + coins
                    HStack {
                        Text(gameState.equippedOutfit.emoji)
                            .font(.system(size: 44))
                        VStack(alignment: .leading) {
                            Text("Whiskers")
                                .font(.title2.bold())
                            HStack(spacing: 4) {
                                Text("🐟")
                                Text("\(gameState.fishCoins)")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                        }
                        Spacer()
                        StreakBadge(streak: gameState.currentStreak)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)

                    // World Cards
                    ForEach(gameState.worlds) { world in
                        WorldCard(world: world)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("KittyIQ Puzzles")
        }
    }
}

// MARK: - World Card

struct WorldCard: View {
    let world: World
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private var isAccessible: Bool {
        if !world.requiresPremium { return true }
        // World 2 first 5 levels are free
        if world.id == 2 { return true }
        return storeManager.isPremium
    }

    private var completedCount: Int {
        world.levels.filter { gameState.completedLevels["\(world.id)-\($0.id)"] != nil }.count
    }

    var body: some View {
        NavigationLink {
            if isAccessible {
                LevelSelectView(world: world)
            } else {
                PremiumUpsellView()
            }
        } label: {
            HStack(spacing: 16) {
                Text(world.emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isAccessible ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(world.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        if world.requiresPremium && !storeManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text("\(completedCount)/\(world.levels.count) levels")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Star progress
                    let totalStars = world.levels.reduce(0) { $0 + (gameState.starsForLevel("\(world.id)-\($1.id)")) }
                    let maxStars = world.levels.count * 3
                    ProgressView(value: Double(totalStars), total: Double(maxStars))
                        .tint(.orange)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("🔥")
                .font(.title3)
            Text("\(streak)")
                .font(.caption.bold())
                .foregroundColor(.orange)
        }
        .frame(width: 50, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
    }
}

#Preview {
    WorldMapView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
