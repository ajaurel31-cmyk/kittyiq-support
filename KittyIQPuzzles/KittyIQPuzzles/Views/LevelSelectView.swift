import SwiftUI

struct LevelSelectView: View {
    let world: World
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // World hero
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.worldGradient(for: world.theme))
                        .frame(height: 120)

                    VStack(spacing: 6) {
                        Image(systemName: AppTheme.worldIcon(for: world.theme))
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                        Text(world.name)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                // Level grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(world.levels) { level in
                        LevelButton(level: level, world: world)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppTheme.surface.ignoresSafeArea())
        .navigationTitle(world.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LevelButton: View {
    let level: Level
    let world: World
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private var isUnlocked: Bool {
        if world.requiresPremium && !storeManager.isPremium {
            if world.id == 2 && level.id <= 5 {
                return gameState.isLevelUnlocked(worldId: world.id, levelId: level.id)
            }
            return false
        }
        return gameState.isLevelUnlocked(worldId: world.id, levelId: level.id)
    }

    private var stars: Int {
        gameState.starsForLevel(level.globalId)
    }

    var body: some View {
        NavigationLink {
            if isUnlocked {
                PuzzleView(level: level)
            } else if !storeManager.isPremium && world.requiresPremium {
                PremiumUpsellView()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isUnlocked ? AppTheme.worldGradient(for: world.theme) : LinearGradient(colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 52, height: 52)

                    if isUnlocked {
                        Text("\(level.id)")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    }
                }

                // Stars
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= stars ? "star.fill" : "star")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(i <= stars ? AppTheme.gold : AppTheme.textSecondary.opacity(0.25))
                    }
                }
            }
        }
        .disabled(!isUnlocked)
    }
}

#Preview {
    NavigationStack {
        LevelSelectView(world: WorldBuilder.buildAllWorlds()[0])
            .environmentObject(GameState())
            .environmentObject(StoreManager())
    }
}
