import SwiftUI

// MARK: - Matching Puzzle Engine

class MatchingPuzzleEngine: ObservableObject {
    @Published var tiles: [Tile] = []
    @Published var selectedTiles: [Int] = []
    @Published var matchedPairs: Set<Int> = []
    @Published var moves: Int = 0
    @Published var isComplete: Bool = false
    @Published var startTime: Date = Date()

    let gridSize: Int
    let catEmojis = ["🐱", "🐈", "😺", "😸", "😻", "🙀", "😽", "😹", "🐈‍⬛", "😾", "🐾", "🐟", "🧶"]

    struct Tile: Identifiable {
        let id: Int
        let emoji: String
        var isRevealed: Bool = false
        var isMatched: Bool = false
    }

    init(gridSize: Int) {
        self.gridSize = gridSize
        setupBoard()
    }

    func setupBoard() {
        let totalTiles = gridSize * gridSize
        // Make it even for pairs
        let pairCount = totalTiles / 2
        let selectedEmojis = Array(catEmojis.prefix(pairCount))
        var allEmojis = selectedEmojis + selectedEmojis
        // If odd number of tiles, add one extra
        if totalTiles % 2 != 0 {
            allEmojis.append("⭐")
        }
        allEmojis.shuffle()

        tiles = allEmojis.enumerated().map { index, emoji in
            Tile(id: index, emoji: emoji)
        }

        moves = 0
        matchedPairs = []
        selectedTiles = []
        isComplete = false
        startTime = Date()
    }

    func selectTile(at index: Int) {
        guard !tiles[index].isMatched, !tiles[index].isRevealed else { return }
        guard selectedTiles.count < 2 else { return }

        tiles[index].isRevealed = true
        selectedTiles.append(index)

        if selectedTiles.count == 2 {
            moves += 1
            let first = selectedTiles[0]
            let second = selectedTiles[1]

            if tiles[first].emoji == tiles[second].emoji {
                tiles[first].isMatched = true
                tiles[second].isMatched = true
                matchedPairs.insert(first)
                matchedPairs.insert(second)
                selectedTiles = []

                // Check completion
                if matchedPairs.count >= tiles.count - (tiles.count % 2 != 0 ? 1 : 0) {
                    isComplete = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.tiles[first].isRevealed = false
                    self.tiles[second].isRevealed = false
                    self.selectedTiles = []
                }
            }
        }
    }

    func calculateStars() -> Int {
        let optimalMoves = tiles.count / 2
        let ratio = Double(moves) / Double(optimalMoves)
        if ratio <= 1.5 { return 3 }
        if ratio <= 2.5 { return 2 }
        return 1
    }
}

// MARK: - Pattern Puzzle Engine

class PatternPuzzleEngine: ObservableObject {
    @Published var pattern: [Int] = []
    @Published var playerInput: [Int] = []
    @Published var isShowingPattern: Bool = true
    @Published var currentShowIndex: Int = 0
    @Published var isComplete: Bool = false
    @Published var mistakes: Int = 0
    @Published var startTime: Date = Date()

    let gridSize: Int
    let patternLength: Int

    init(gridSize: Int) {
        self.gridSize = gridSize
        self.patternLength = gridSize + 2
        generatePattern()
    }

    func generatePattern() {
        let totalCells = gridSize * gridSize
        pattern = (0..<patternLength).map { _ in Int.random(in: 0..<totalCells) }
        playerInput = []
        mistakes = 0
        isComplete = false
        isShowingPattern = true
        currentShowIndex = 0
        startTime = Date()

        showPatternSequence()
    }

    private func showPatternSequence() {
        for i in 0..<pattern.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7) {
                self.currentShowIndex = i
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(pattern.count) * 0.7 + 0.3) {
            self.isShowingPattern = false
            self.currentShowIndex = -1
        }
    }

    func tapCell(_ index: Int) {
        guard !isShowingPattern else { return }

        let expectedIndex = playerInput.count
        if index == pattern[expectedIndex] {
            playerInput.append(index)
            if playerInput.count == pattern.count {
                isComplete = true
            }
        } else {
            mistakes += 1
            playerInput = []
            // Re-show pattern
            isShowingPattern = true
            currentShowIndex = 0
            showPatternSequence()
        }
    }

    func calculateStars() -> Int {
        if mistakes == 0 { return 3 }
        if mistakes <= 1 { return 2 }
        return 1
    }
}

// MARK: - Sliding Puzzle Engine

class SlidingPuzzleEngine: ObservableObject {
    @Published var tiles: [Int] = []
    @Published var emptyIndex: Int = 0
    @Published var moves: Int = 0
    @Published var isComplete: Bool = false
    @Published var startTime: Date = Date()

    let gridSize: Int

    init(gridSize: Int) {
        self.gridSize = gridSize
        setupBoard()
    }

    func setupBoard() {
        let total = gridSize * gridSize
        tiles = Array(1..<total) + [0] // 0 = empty
        emptyIndex = total - 1
        moves = 0
        isComplete = false
        startTime = Date()

        // Shuffle with valid moves
        for _ in 0..<(gridSize * gridSize * 10) {
            let neighbors = validMoves()
            if let randomNeighbor = neighbors.randomElement() {
                swapTile(at: randomNeighbor, silent: true)
            }
        }
    }

    func validMoves() -> [Int] {
        var moves: [Int] = []
        let row = emptyIndex / gridSize
        let col = emptyIndex % gridSize
        if row > 0 { moves.append(emptyIndex - gridSize) }
        if row < gridSize - 1 { moves.append(emptyIndex + gridSize) }
        if col > 0 { moves.append(emptyIndex - 1) }
        if col < gridSize - 1 { moves.append(emptyIndex + 1) }
        return moves
    }

    func tapTile(at index: Int) {
        guard validMoves().contains(index) else { return }
        swapTile(at: index, silent: false)
    }

    private func swapTile(at index: Int, silent: Bool) {
        tiles.swapAt(index, emptyIndex)
        emptyIndex = index
        if !silent {
            moves += 1
            checkCompletion()
        }
    }

    private func checkCompletion() {
        let total = gridSize * gridSize
        let solved = Array(1..<total) + [0]
        if tiles == solved {
            isComplete = true
        }
    }

    func calculateStars() -> Int {
        let optimal = gridSize * gridSize * 3
        if moves <= optimal { return 3 }
        if moves <= optimal * 2 { return 2 }
        return 1
    }
}
