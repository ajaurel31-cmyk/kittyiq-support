import SwiftUI

struct PremiumUpsellView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Hero
                ZStack {
                    Circle()
                        .fill(AppTheme.premiumGradient)
                        .frame(width: 100, height: 100)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                VStack(spacing: 6) {
                    Text("Go Premium")
                        .font(.title.weight(.bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("One-time purchase. Yours forever.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Feature list
                VStack(spacing: 0) {
                    PremiumFeatureRow(icon: "globe.americas.fill", text: "All 5 Worlds (70+ levels)", color: AppTheme.cityBlue)
                    PremiumFeatureRow(icon: "sparkles", text: "All Whiskers outfits", color: AppTheme.forestPurple)
                    PremiumFeatureRow(icon: "trophy.fill", text: "Full Collection Book", color: AppTheme.gold)
                    PremiumFeatureRow(icon: "leaf.fill", text: "Catnip Bonus levels", color: AppTheme.gardenGreen)
                    PremiumFeatureRow(icon: "moon.stars.fill", text: "Night Mode", color: AppTheme.forestPurple)
                    PremiumFeatureRow(icon: "arrow.up.circle.fill", text: "Free future updates", color: AppTheme.accent)
                }
                .padding(4)
                .solidCard()
                .padding(.horizontal)

                // Price
                VStack(spacing: 6) {
                    if let product = storeManager.premiumProduct {
                        Text(product.displayPrice)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.premiumGradient)
                    } else {
                        Text("$4.99")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.premiumGradient)
                    }
                    Text("One-time purchase — no subscription")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Purchase button
                Button {
                    Task {
                        isPurchasing = true
                        let success = await storeManager.purchasePremium()
                        isPurchasing = false
                        if success { dismiss() }
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                                .font(.subheadline)
                            Text("Unlock Premium")
                        }
                    }
                    .accentButton()
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 32)

                // Restore
                Button {
                    Task { await storeManager.restorePurchases() }
                } label: {
                    Text("Restore Purchase")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                if let error = storeManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppTheme.surface.ignoresSafeArea())
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        PremiumUpsellView()
            .environmentObject(StoreManager())
    }
}
