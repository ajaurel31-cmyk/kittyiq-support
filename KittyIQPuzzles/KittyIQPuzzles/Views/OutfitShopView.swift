import SwiftUI

struct OutfitShopView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current outfit preview
                    VStack(spacing: 8) {
                        Text(gameState.equippedOutfit.emoji)
                            .font(.system(size: 80))
                        Text(gameState.equippedOutfit.name)
                            .font(.headline)
                        Text("Currently Equipped")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .padding(.horizontal)

                    // Coins
                    HStack {
                        Text("🐟 \(gameState.fishCoins) Fish Coins")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Outfit grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(gameState.allOutfits) { outfit in
                            OutfitCard(outfit: outfit)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Outfits")
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
        VStack(spacing: 10) {
            Text(outfit.emoji)
                .font(.system(size: 44))

            Text(outfit.name)
                .font(.subheadline.bold())
                .lineLimit(1)

            if isEquipped {
                Text("Equipped")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.2)))
                    .foregroundColor(.green)
            } else if isOwned {
                Button("Equip") {
                    gameState.equipOutfit(outfit)
                }
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.orange))
                .foregroundColor(.white)
            } else if !canAccess {
                Label("Premium", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Button("🐟 \(outfit.cost)") {
                    _ = gameState.buyOutfit(outfit)
                }
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(gameState.fishCoins >= outfit.cost ? Color.orange : Color.gray))
                .foregroundColor(.white)
                .disabled(gameState.fishCoins < outfit.cost)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }
}

#Preview {
    OutfitShopView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
