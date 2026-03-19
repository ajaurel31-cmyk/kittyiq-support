import SwiftUI

struct PuzzleView: View {
    let level: Level
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var matchingEngine: MatchingPuzzleEngine
    @StateObject private var patternEngine: PatternPuzzleEngine
    @StateObject private var slidingEngine: SlidingPuzzleEngine

    @State private var showResult = false
    @State private var resultStars = 0

    init(level: Level) {
        self.level = level
        let size = level.difficulty.gridSize
        _matchingEngine = StateObject(wrappedValue: MatchingPuzzleEngine(gridSize: size))
        _patternEngine = StateObject(wrappedValue: PatternPuzzleEngine(gridSize: size))
        _slidingEngine = StateObject(wrappedValue: SlidingPuzzleEngine(gridSize: size))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level.id)")
                        .font(.headline)
                    Text(level.puzzleType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("🐟")
                    Text("+\(level.fishCoinReward)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // Puzzle area
            Group {
                switch level.puzzleType {
                case .matching, .memory:
                    MatchingGridView(engine: matchingEngine, gridSize: level.difficulty.gridSize)
                case .pattern:
                    PatternGridView(engine: patternEngine, gridSize: level.difficulty.gridSize)
                case .sliding:
                    SlidingGridView(engine: slidingEngine, gridSize: level.difficulty.gridSize)
                }
            }
            .padding()

            // Move counter
            HStack {
                Text("Moves: \(currentMoves)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(level.difficulty.label)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.15)))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isComplete) { _, complete in
            if complete {
                let stars = calculateStars()
                resultStars = stars
                let result = LevelResult(
                    levelId: level.globalId,
                    stars: stars,
                    fishCoinsEarned: level.fishCoinReward * stars,
                    timeSeconds: Date().timeIntervalSince(startTime)
                )
                gameState.completeLevel(result)
                showResult = true
            }
        }
        .sheet(isPresented: $showResult) {
            LevelCompleteView(stars: resultStars, coins: level.fishCoinReward * resultStars) {
                dismiss()
            }
        }
    }

    private var currentMoves: Int {
        switch level.puzzleType {
        case .matching, .memory: return matchingEngine.moves
        case .pattern: return patternEngine.mistakes
        case .sliding: return slidingEngine.moves
        }
    }

    private var isComplete: Bool {
        switch level.puzzleType {
        case .matching, .memory: return matchingEngine.isComplete
        case .pattern: return patternEngine.isComplete
        case .sliding: return slidingEngine.isComplete
        }
    }

    private var startTime: Date {
        switch level.puzzleType {
        case .matching, .memory: return matchingEngine.startTime
        case .pattern: return patternEngine.startTime
        case .sliding: return slidingEngine.startTime
        }
    }

    private func calculateStars() -> Int {
        switch level.puzzleType {
        case .matching, .memory: return matchingEngine.calculateStars()
        case .pattern: return patternEngine.calculateStars()
        case .sliding: return slidingEngine.calculateStars()
        }
    }
}

// MARK: - Matching Grid

struct MatchingGridView: View {
    @ObservedObject var engine: MatchingPuzzleEngine
    let gridSize: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(engine.tiles) { tile in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        engine.selectTile(at: tile.id)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tile.isMatched ? Color.green.opacity(0.3) : (tile.isRevealed ? Color.orange.opacity(0.2) : Color.orange))
                            .aspectRatio(1, contentMode: .fit)

                        if tile.isRevealed || tile.isMatched {
                            Text(tile.emoji)
                                .font(.system(size: tileEmojiSize))
                                .transition(.scale)
                        } else {
                            Text("🐾")
                                .font(.system(size: tileEmojiSize * 0.7))
                                .opacity(0.5)
                        }
                    }
                }
                .disabled(tile.isMatched)
            }
        }
    }

    private var tileEmojiSize: CGFloat {
        switch gridSize {
        case 3: return 32
        case 4: return 26
        default: return 22
        }
    }
}

// MARK: - Pattern Grid

struct PatternGridView: View {
    @ObservedObject var engine: PatternPuzzleEngine
    let gridSize: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize)
    }

    var body: some View {
        VStack(spacing: 16) {
            if engine.isShowingPattern {
                Text("Watch the pattern...")
                    .font(.headline)
                    .foregroundColor(.orange)
            } else {
                Text("Repeat the pattern! (\(engine.playerInput.count)/\(engine.patternLength))")
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                    Button {
                        engine.tapCell(index)
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(cellColor(for: index))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Text("🐱")
                                    .font(.title2)
                                    .opacity(isHighlighted(index) ? 1 : 0.2)
                            )
                    }
                    .disabled(engine.isShowingPattern)
                }
            }
        }
    }

    private func isHighlighted(_ index: Int) -> Bool {
        if engine.isShowingPattern {
            return engine.currentShowIndex >= 0 && engine.currentShowIndex < engine.pattern.count && engine.pattern[engine.currentShowIndex] == index
        }
        return false
    }

    private func cellColor(for index: Int) -> Color {
        if isHighlighted(index) {
            return .orange
        }
        if engine.playerInput.contains(index) {
            return .green.opacity(0.3)
        }
        return .orange.opacity(0.15)
    }
}

// MARK: - Sliding Grid

struct SlidingGridView: View {
    @ObservedObject var engine: SlidingPuzzleEngine
    let gridSize: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize)
    }

    private let catParts = ["😺", "😸", "😻", "😽", "🙀", "😹", "😾", "😿", "🐱", "😼", "🐈", "🐈‍⬛", "🐾", "🧶", "🐟", "🎣", "🥛", "🐭", "🪶", "🧸", "🛋️", "📦", "🌿", "🐦"]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<engine.tiles.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        engine.tapTile(at: index)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(engine.tiles[index] == 0 ? Color.clear : Color.orange)
                            .aspectRatio(1, contentMode: .fit)

                        if engine.tiles[index] != 0 {
                            Text(catParts[(engine.tiles[index] - 1) % catParts.count])
                                .font(.system(size: tileFontSize))
                        }
                    }
                }
                .disabled(engine.tiles[index] == 0)
            }
        }
    }

    private var tileFontSize: CGFloat {
        switch gridSize {
        case 3: return 30
        case 4: return 24
        default: return 20
        }
    }
}

// MARK: - Level Complete

struct LevelCompleteView: View {
    let stars: Int
    let coins: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("🎉")
                .font(.system(size: 60))

            Text("Level Complete!")
                .font(.title.bold())

            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { i in
                    Image(systemName: i <= stars ? "star.fill" : "star")
                        .font(.system(size: 36))
                        .foregroundColor(i <= stars ? .yellow : .gray.opacity(0.3))
                }
            }

            HStack(spacing: 4) {
                Text("🐟")
                    .font(.title2)
                Text("+\(coins)")
                    .font(.title.bold())
                    .foregroundColor(.orange)
            }

            Button {
                onDismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        PuzzleView(level: Level(id: 1, worldId: 1, puzzleType: .matching, difficulty: .easy, fishCoinReward: 15, isLocked: false))
            .environmentObject(GameState())
    }
}
