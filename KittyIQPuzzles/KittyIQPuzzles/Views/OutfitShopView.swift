import SwiftUI

struct OutfitShopView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current outfit showcase
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.heroGradient)
                                .frame(width: 90, height: 90)
                            Text(gameState.equippedOutfit.emoji)
                                .font(.system(size: 44))
                        }
                        Text(gameState.equippedOutfit.name)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Currently Equipped")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)

                    // Coin balance
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(AppTheme.coinColor)
                        Text("\(gameState.fishCoins)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("coins")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Outfit grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(gameState.allOutfits) { outfit in
                            OutfitCard(outfit: outfit)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationTitle("Style")
        }
    }
}

struct OutfitCard: View {
    let outfit: CatOutfit
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private var isOwned: Bool {
        gameState.unlockedOutfits.contains(outfit.id)
    }

    private var isEquipped: Bool {
        gameState.equippedOutfitId == outfit.id
    }

    private var canAccess: Bool {
        !outfit.requiresPremium || storeManager.isPremium
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isEquipped ? AppTheme.accent.opacity(0.12) : Color.gray.opacity(0.06))
                    .frame(width: 60, height: 60)
                Text(outfit.emoji)
                    .font(.system(size: 30))
            }

            Text(outfit.name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            if isEquipped {
                Label("Equipped", systemImage: "checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppTheme.success)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(AppTheme.success.opacity(0.12)))
            } else if isOwned {
                Button {
                    gameState.equipOutfit(outfit)
                } label: {
                    Text("Equip")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(AppTheme.accent))
                }
            } else if !canAccess {
                Label("Premium", systemImage: "lock.fill")
                    .font(.caption.weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                Button {
                    _ = gameState.buyOutfit(outfit)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 10))
                        Text("\(outfit.cost)")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(gameState.fishCoins >= outfit.cost ? AppTheme.accent : Color.gray.opacity(0.4))
                    )
                }
                .disabled(gameState.fishCoins < outfit.cost)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .solidCard()
    }
}

#Preview {
    OutfitShopView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
