import SwiftUI

struct LevelSelectView: View {
    let world: World
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // World header
                Text(world.emoji)
                    .font(.system(size: 60))
                Text(world.name)
                    .font(.title.bold())

                // Level grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(world.levels) { level in
                        LevelButton(level: level, world: world)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
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
        // Premium levels beyond free tier
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
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isUnlocked ? Color.orange : Color.gray.opacity(0.2))
                        .frame(width: 54, height: 54)

                    if isUnlocked {
                        Text("\(level.id)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                // Stars
                HStack(spacing: 1) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= stars ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(i <= stars ? .yellow : .gray.opacity(0.3))
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
