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
        VStack(spacing: 0) {
            // Header bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(level.id)")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(level.puzzleType.rawValue)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.coinColor)
                        .font(.subheadline)
                    Text("\(level.fishCoinReward)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.coinColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(AppTheme.coinColor.opacity(0.12))
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

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
            .padding(.horizontal)

            Spacer()

            // Bottom stats bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(currentMoves) moves")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                Text(level.difficulty.label)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(AppTheme.accent.opacity(0.1))
                    )
                    .foregroundColor(AppTheme.accent)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(AppTheme.surface.ignoresSafeArea())
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.selectTile(at: tile.id)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tileBackground(tile))
                            .aspectRatio(1, contentMode: .fit)

                        if tile.isRevealed || tile.isMatched {
                            Text(tile.emoji)
                                .font(.system(size: tileEmojiSize))
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: tileEmojiSize * 0.5))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .disabled(tile.isMatched)
            }
        }
    }

    private func tileBackground(_ tile: MatchingPuzzleEngine.Tile) -> some ShapeStyle {
        if tile.isMatched {
            return AnyShapeStyle(AppTheme.success.opacity(0.25))
        } else if tile.isRevealed {
            return AnyShapeStyle(AppTheme.accent.opacity(0.15))
        } else {
            return AnyShapeStyle(AppTheme.heroGradient)
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
                HStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                        .font(.subheadline)
                    Text("Watch the pattern")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.accent)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.subheadline)
                    Text("Repeat: \(engine.playerInput.count)/\(engine.patternLength)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.textPrimary)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                    Button {
                        engine.tapCell(index)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(cellColor(for: index))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .opacity(isHighlighted(index) ? 1 : 0.15)
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
            return AppTheme.accent
        }
        if engine.playerInput.contains(index) {
            return AppTheme.success.opacity(0.4)
        }
        return AppTheme.accent.opacity(0.1)
    }
}

// MARK: - Sliding Grid

struct SlidingGridView: View {
    @ObservedObject var engine: SlidingPuzzleEngine
    let gridSize: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize)
    }

    private let tileSymbols = [
        "cat.fill", "hare.fill", "bird.fill", "fish.fill", "tortoise.fill",
        "ant.fill", "ladybug.fill", "leaf.fill", "star.fill", "heart.fill",
        "moon.fill", "sun.max.fill", "cloud.fill", "bolt.fill", "drop.fill",
        "flame.fill", "snowflake", "wind", "sparkle", "circle.hexagongrid.fill",
        "diamond.fill", "triangle.fill", "pentagon.fill", "hexagon.fill"
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<engine.tiles.count, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        engine.tapTile(at: index)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(engine.tiles[index] == 0 ? AnyShapeStyle(Color.clear) : AnyShapeStyle(AppTheme.heroGradient))
                            .aspectRatio(1, contentMode: .fit)

                        if engine.tiles[index] != 0 {
                            Image(systemName: tileSymbols[(engine.tiles[index] - 1) % tileSymbols.count])
                                .font(.system(size: tileFontSize, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(engine.tiles[index] == 0)
            }
        }
    }

    private var tileFontSize: CGFloat {
        switch gridSize {
        case 3: return 26
        case 4: return 20
        default: return 16
        }
    }
}

// MARK: - Level Complete

struct LevelCompleteView: View {
    let stars: Int
    let coins: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.heroGradient)
            }

            Text("Level Complete")
                .font(.title2.weight(.bold))
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 10) {
                ForEach(1...3, id: \.self) { i in
                    Image(systemName: i <= stars ? "star.fill" : "star")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(i <= stars ? AppTheme.gold : AppTheme.textSecondary.opacity(0.2))
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(AppTheme.coinColor)
                Text("+\(coins)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(AppTheme.coinColor)
            }

            Button {
                onDismiss()
            } label: {
                Text("Continue")
                    .accentButton()
            }
            .padding(.horizontal, 40)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        PuzzleView(level: Level(id: 1, worldId: 1, puzzleType: .matching, difficulty: .easy, fishCoinReward: 15, isLocked: false))
            .environmentObject(GameState())
    }
}
