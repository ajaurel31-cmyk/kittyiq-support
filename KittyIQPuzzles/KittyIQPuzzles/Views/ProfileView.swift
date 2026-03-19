import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.heroGradient)
                                .frame(width: 80, height: 80)
                            Text(gameState.equippedOutfit.emoji)
                                .font(.system(size: 40))
                        }

                        Text("Whiskers")
                            .font(.title2.weight(.bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(gameState.equippedOutfit.name)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)

                    // Stats grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Statistics")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            StatCard(icon: "checkmark.circle.fill", label: "Completed", value: "\(gameState.totalLevelsCompleted)", color: AppTheme.success)
                            StatCard(icon: "star.fill", label: "Stars", value: "\(gameState.totalStars)", color: AppTheme.gold)
                            StatCard(icon: "dollarsign.circle.fill", label: "Coins", value: "\(gameState.fishCoins)", color: AppTheme.coinColor)
                            StatCard(icon: "flame.fill", label: "Streak", value: "\(gameState.currentStreak)", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                        }
                        .padding(.horizontal)
                    }

                    // Premium section
                    VStack(spacing: 0) {
                        if storeManager.isPremium {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title3)
                                    .foregroundStyle(AppTheme.premiumGradient)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Premium Active")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("Lifetime access")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                        } else {
                            NavigationLink {
                                PremiumUpsellView()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "crown.fill")
                                        .font(.title3)
                                        .foregroundStyle(AppTheme.premiumGradient)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Unlock Premium")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("All worlds, outfits & more")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text("$4.99")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(AppTheme.accent)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                }
                                .padding(16)
                            }
                        }

                        Divider().padding(.horizontal)

                        Button {
                            Task { await storeManager.restorePurchases() }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.subheadline)
                                Text("Restore Purchase")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(16)
                        }
                    }
                    .solidCard()
                    .padding(.horizontal)

                    // About section
                    VStack(spacing: 0) {
                        AboutRow(icon: "info.circle", label: "Version", detail: "1.0.0")
                        Divider().padding(.horizontal)
                        NavigationLink {
                            Text("Privacy Policy content here")
                        } label: {
                            AboutRow(icon: "hand.raised.fill", label: "Privacy Policy", showChevron: true)
                        }
                        Divider().padding(.horizontal)
                        NavigationLink {
                            Text("EULA content here")
                        } label: {
                            AboutRow(icon: "doc.text.fill", label: "Terms of Use", showChevron: true)
                        }
                    }
                    .solidCard()
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationTitle("Profile")
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .solidCard()
    }
}

struct AboutRow: View {
    let icon: String
    let label: String
    var detail: String? = nil
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            }
        }
        .padding(16)
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
