import SwiftUI

struct PremiumUpsellView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cat graphic
                Text("😻")
                    .font(.system(size: 80))
                    .padding(.top, 20)

                Text("Unlock KittyIQ Premium")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("One-time purchase. Yours forever.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Feature list
                VStack(alignment: .leading, spacing: 14) {
                    FeatureRow(emoji: "🌍", text: "All 5 Worlds (70+ levels)")
                    FeatureRow(emoji: "🐱", text: "All Whiskers outfits")
                    FeatureRow(emoji: "📖", text: "Full Collection Book")
                    FeatureRow(emoji: "✨", text: "Catnip Bonus levels")
                    FeatureRow(emoji: "🌙", text: "Night Mode")
                    FeatureRow(emoji: "🆕", text: "Free future updates included")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.08))
                )
                .padding(.horizontal)

                // Price
                VStack(spacing: 8) {
                    if let product = storeManager.premiumProduct {
                        Text(product.displayPrice)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.orange)
                    } else {
                        Text("$4.99")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    Text("One-time purchase — no subscription")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Purchase button
                Button {
                    Task {
                        isPurchasing = true
                        let success = await storeManager.purchasePremium()
                        isPurchasing = false
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Unlock Premium")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 32)

                // Restore
                Button {
                    Task {
                        await storeManager.restorePurchases()
                    }
                } label: {
                    Text("Restore Purchase")
                        .font(.subheadline)
                        .foregroundColor(.orange)
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
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title3)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        PremiumUpsellView()
            .environmentObject(StoreManager())
    }
}
