import SwiftUI

class GameState: ObservableObject {
    @AppStorage("fishCoins") var fishCoins: Int = 0
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("lastPlayDate") var lastPlayDateString: String = ""
    @AppStorage("equippedOutfit") var equippedOutfitId: String = "default"
    @Published var completedLevels: [String: Int] = [:] // levelId -> stars
    @Published var unlockedOutfits: Set<String> = ["default", "collar"]
    @Published var collectedItems: Set<String> = []

    private let completedLevelsKey = "completedLevels"
    private let unlockedOutfitsKey = "unlockedOutfits"
    private let collectedItemsKey = "collectedItems"

    init() {
        loadProgress()
        updateStreak()
    }

    // MARK: - Worlds & Levels

    var worlds: [World] {
        WorldBuilder.buildAllWorlds()
    }

    func starsForLevel(_ levelId: String) -> Int {
        completedLevels[levelId] ?? 0
    }

    func isLevelUnlocked(worldId: Int, levelId: Int) -> Bool {
        if worldId == 1 { // World 1 always free
            if levelId == 1 { return true }
            let prevId = "\(worldId)-\(levelId - 1)"
            return completedLevels[prevId] != nil
        }
        // World 2 first 5 levels are free teaser
        if worldId == 2 && levelId <= 5 {
            if levelId == 1 {
                // Need to complete world 1
                let lastWorld1 = "\(1)-15"
                return completedLevels[lastWorld1] != nil
            }
            let prevId = "\(worldId)-\(levelId - 1)"
            return completedLevels[prevId] != nil
        }
        // Everything else needs premium
        return false // StoreManager handles premium check separately
    }

    // MARK: - Level Completion

    func completeLevel(_ result: LevelResult) {
        let existing = completedLevels[result.levelId] ?? 0
        if result.stars > existing {
            completedLevels[result.levelId] = result.stars
        }
        fishCoins += result.fishCoinsEarned
        saveProgress()
    }

    // MARK: - Outfits

    var allOutfits: [CatOutfit] {
        [
            CatOutfit(id: "default", name: "Classic Whiskers", emoji: "🐱", cost: 0, requiresPremium: false),
            CatOutfit(id: "collar", name: "Red Collar", emoji: "😺", cost: 0, requiresPremium: false),
            CatOutfit(id: "tophat", name: "Top Hat", emoji: "🎩", cost: 100, requiresPremium: true),
            CatOutfit(id: "pirate", name: "Pirate Cat", emoji: "🏴‍☠️", cost: 150, requiresPremium: true),
            CatOutfit(id: "wizard", name: "Wizard Cat", emoji: "🧙", cost: 200, requiresPremium: true),
            CatOutfit(id: "astronaut", name: "Space Cat", emoji: "🚀", cost: 250, requiresPremium: true),
            CatOutfit(id: "ninja", name: "Ninja Cat", emoji: "🥷", cost: 200, requiresPremium: true),
            CatOutfit(id: "crown", name: "Royal Cat", emoji: "👑", cost: 300, requiresPremium: true),
        ]
    }

    var equippedOutfit: CatOutfit {
        allOutfits.first { $0.id == equippedOutfitId } ?? allOutfits[0]
    }

    func buyOutfit(_ outfit: CatOutfit) -> Bool {
        guard fishCoins >= outfit.cost else { return false }
        fishCoins -= outfit.cost
        unlockedOutfits.insert(outfit.id)
        saveProgress()
        return true
    }

    func equipOutfit(_ outfit: CatOutfit) {
        equippedOutfitId = outfit.id
    }

    // MARK: - Streak

    func updateStreak() {
        let today = dateString(Date())
        if lastPlayDateString == yesterday() {
            currentStreak += 1
        } else if lastPlayDateString != today {
            currentStreak = 1
        }
        lastPlayDateString = today
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func yesterday() -> String {
        let cal = Calendar.current
        let y = cal.date(byAdding: .day, value: -1, to: Date())!
        return dateString(y)
    }

    // MARK: - Persistence

    func saveProgress() {
        UserDefaults.standard.set(completedLevels, forKey: completedLevelsKey)
        UserDefaults.standard.set(Array(unlockedOutfits), forKey: unlockedOutfitsKey)
        UserDefaults.standard.set(Array(collectedItems), forKey: collectedItemsKey)
    }

    func loadProgress() {
        if let saved = UserDefaults.standard.dictionary(forKey: completedLevelsKey) as? [String: Int] {
            completedLevels = saved
        }
        if let saved = UserDefaults.standard.stringArray(forKey: unlockedOutfitsKey) {
            unlockedOutfits = Set(saved)
        }
        if let saved = UserDefaults.standard.stringArray(forKey: collectedItemsKey) {
            collectedItems = Set(saved)
        }
    }

    // MARK: - Stats

    var totalStars: Int {
        completedLevels.values.reduce(0, +)
    }

    var totalLevelsCompleted: Int {
        completedLevels.count
    }
}
