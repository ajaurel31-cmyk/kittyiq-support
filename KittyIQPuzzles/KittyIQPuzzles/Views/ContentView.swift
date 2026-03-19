import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        TabView {
            WorldMapView()
                .tabItem {
                    Label("Worlds", systemImage: "map.fill")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "book.fill")
                }

            OutfitShopView()
                .tabItem {
                    Label("Outfits", systemImage: "tshirt.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
        .environmentObject(StoreManager())
}
