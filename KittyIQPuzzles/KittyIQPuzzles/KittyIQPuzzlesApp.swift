import SwiftUI

@main
struct KittyIQPuzzlesApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(storeManager)
        }
    }
}
