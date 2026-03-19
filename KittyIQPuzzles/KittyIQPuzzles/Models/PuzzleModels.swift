import Foundation

// MARK: - World

struct World: Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let theme: WorldTheme
    let levels: [Level]
    let requiresPremium: Bool
}

enum WorldTheme: String, CaseIterable {
    case garden = "Garden"
    case house = "Cozy House"
    case city = "City Rooftops"
    case enchanted = "Enchanted Forest"
    case bonus = "Catnip Dreams"

    var primaryColor: String {
        switch self {
        case .garden: return "GardenGreen"
        case .house: return "HouseOrange"
        case .city: return "CityBlue"
        case .enchanted: return "ForestPurple"
        case .bonus: return "BonusPink"
        }
    }
}

// MARK: - Level

struct Level: Identifiable {
    let id: Int
    let worldId: Int
    let puzzleType: PuzzleType
    let difficulty: Difficulty
    let fishCoinReward: Int
    let isLocked: Bool

    var globalId: String { "\(worldId)-\(id)" }
}

enum PuzzleType: String, CaseIterable {
    case matching = "Matching"
    case sliding = "Sliding"
    case memory = "Memory"
    case pattern = "Pattern"
}

enum Difficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3

    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }

    var label: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

// MARK: - Cat Outfit

struct CatOutfit: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let cost: Int
    let requiresPremium: Bool
}

// MARK: - Collectible

struct Collectible: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let worldId: Int
}

// MARK: - Level Result

struct LevelResult {
    let levelId: String
    let stars: Int // 1-3
    let fishCoinsEarned: Int
    let timeSeconds: Double
}
