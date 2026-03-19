import StoreKit
import SwiftUI

private typealias StoreTransaction = StoreKit.Transaction

@MainActor
class StoreManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var purchaseInProgress: Bool = false
    @Published var errorMessage: String?

    static let premiumProductId = "com.kittyiq.puzzles.premium"
    static let coinPackProductId = "com.kittyiq.puzzles.coinpack"

    private var transactionListener: Task<Void, Error>?

    init() {
        // Check stored premium status
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")

        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let productIds = [
                StoreManager.premiumProductId,
                StoreManager.coinPackProductId
            ]
            products = try await Product.products(for: productIds)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try StoreManager.checkVerified(verification)
                await handleTransaction(transaction)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    func purchasePremium() async -> Bool {
        guard let product = products.first(where: { $0.id == StoreManager.premiumProductId }) else {
            errorMessage = "Premium product not found"
            return false
        }
        return await purchase(product)
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Transaction Handling

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in StoreTransaction.updates {
                do {
                    let transaction = try StoreManager.checkVerified(result)
                    await self.handleTransaction(transaction)
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }

    private func handleTransaction(_ transaction: StoreTransaction) async {
        if transaction.productID == StoreManager.premiumProductId {
            isPremium = true
            UserDefaults.standard.set(true, forKey: "isPremium")
        }
    }

    private nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.verificationFailed
        }
    }

    private func updatePurchaseStatus() async {
        for await result in StoreTransaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == StoreManager.premiumProductId {
                    isPremium = true
                    UserDefaults.standard.set(true, forKey: "isPremium")
                    return
                }
            }
        }
    }

    // MARK: - Helpers

    var premiumProduct: Product? {
        products.first { $0.id == StoreManager.premiumProductId }
    }

    var coinPackProduct: Product? {
        products.first { $0.id == StoreManager.coinPackProductId }
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
