import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        NavigationStack {
            List {
                // Cat Profile
                Section {
                    HStack(spacing: 16) {
                        Text(gameState.equippedOutfit.emoji)
                            .font(.system(size: 50))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Whiskers")
                                .font(.title2.bold())
                            Text(gameState.equippedOutfit.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Stats
                Section("Stats") {
                    StatRow(label: "Levels Completed", value: "\(gameState.totalLevelsCompleted)")
                    StatRow(label: "Total Stars", value: "⭐ \(gameState.totalStars)")
                    StatRow(label: "Fish Coins", value: "🐟 \(gameState.fishCoins)")
                    StatRow(label: "Daily Streak", value: "🔥 \(gameState.currentStreak)")
                    StatRow(label: "Outfits Owned", value: "\(gameState.unlockedOutfits.count)/\(gameState.allOutfits.count)")
                }

                // Premium
                Section("KittyIQ Premium") {
                    if storeManager.isPremium {
                        HStack {
                            Label("Premium Active", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Text("Lifetime")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        NavigationLink {
                            PremiumUpsellView()
                        } label: {
                            HStack {
                                Label("Unlock Premium", systemImage: "star.fill")
                                    .foregroundColor(.orange)
                                Spacer()
                                Text("$4.99")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    Button("Restore Purchase") {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    NavigationLink("Privacy Policy") {
                        // In a real app, open the web page
                        Text("Privacy Policy content here")
                    }
                    NavigationLink("Terms of Use") {
                        Text("EULA content here")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
