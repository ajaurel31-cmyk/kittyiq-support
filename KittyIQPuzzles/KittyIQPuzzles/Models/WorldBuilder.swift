import Foundation

struct WorldBuilder {
    static func buildAllWorlds() -> [World] {
        return [
            buildWorld(id: 1, name: "Whiskers' Garden", emoji: "🌿", theme: .garden, levelCount: 15, requiresPremium: false),
            buildWorld(id: 2, name: "Cozy House", emoji: "🏠", theme: .house, levelCount: 15, requiresPremium: false), // first 5 free
            buildWorld(id: 3, name: "City Rooftops", emoji: "🏙️", theme: .city, levelCount: 15, requiresPremium: true),
            buildWorld(id: 4, name: "Enchanted Forest", emoji: "🌙", theme: .enchanted, levelCount: 15, requiresPremium: true),
            buildWorld(id: 5, name: "Catnip Dreams", emoji: "✨", theme: .bonus, levelCount: 10, requiresPremium: true),
        ]
    }

    private static func buildWorld(id: Int, name: String, emoji: String, theme: WorldTheme, levelCount: Int, requiresPremium: Bool) -> World {
        let puzzleTypes = PuzzleType.allCases
        var levels: [Level] = []

        for i in 1...levelCount {
            let difficulty: Difficulty
            if i <= 5 { difficulty = .easy }
            else if i <= 10 { difficulty = .medium }
            else { difficulty = .hard }

            let puzzleType = puzzleTypes[(i - 1) % puzzleTypes.count]
            let reward = difficulty.rawValue * 10 + (id * 5)

            levels.append(Level(
                id: i,
                worldId: id,
                puzzleType: puzzleType,
                difficulty: difficulty,
                fishCoinReward: reward,
                isLocked: false
            ))
        }

        return World(id: id, name: name, emoji: emoji, theme: theme, levels: levels, requiresPremium: requiresPremium)
    }
}
