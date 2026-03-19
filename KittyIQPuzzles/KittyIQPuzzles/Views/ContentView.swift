import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        TabView {
            WorldMapView()
                .tabItem {
                    Label("Worlds", systemImage: "globe.americas.fill")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2.fill")
                }

            OutfitShopView()
                .tabItem {
                    Label("Style", systemImage: "sparkles")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
