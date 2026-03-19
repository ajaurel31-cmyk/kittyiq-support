import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero header card
                    HStack(spacing: 14) {
                        // Cat avatar circle
                        ZStack {
                            Circle()
                                .fill(AppTheme.heroGradient)
                                .frame(width: 56, height: 56)
                            Text(gameState.equippedOutfit.emoji)
                                .font(.system(size: 28))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Whiskers")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            HStack(spacing: 6) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(AppTheme.coinColor)
                                    .font(.subheadline)
                                Text("\(gameState.fishCoins)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }

                        Spacer()

                        StreakBadge(streak: gameState.currentStreak)
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal)

                    // World cards
                    ForEach(gameState.worlds) { world in
                        WorldCard(world: world)
                    }
                }
                .padding(.vertical)
            }
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationTitle("KittyIQ")
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
            HStack(spacing: 14) {
                // World icon with themed gradient
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.worldGradient(for: world.theme))
                        .frame(width: 52, height: 52)
                    Image(systemName: AppTheme.worldIcon(for: world.theme))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(world.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        if world.requiresPremium && !storeManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    Text("\(completedCount)/\(world.levels.count) levels")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    // Star progress bar
                    let totalStars = world.levels.reduce(0) { $0 + (gameState.starsForLevel("\(world.id)-\($1.id)")) }
                    let maxStars = world.levels.count * 3
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.accent.opacity(0.12))
                                .frame(height: 4)
                            Capsule()
                                .fill(AppTheme.worldColor(for: world.theme))
                                .frame(width: maxStars > 0 ? geo.size.width * CGFloat(totalStars) / CGFloat(maxStars) : 0, height: 4)
                        }
                    }
                    .frame(height: 4)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            }
            .padding(14)
            .solidCard()
            .padding(.horizontal)
        }
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.subheadline)
                .foregroundColor(.white)
            Text("\(streak)")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.45, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.35)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#Preview {
    WorldMapView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
